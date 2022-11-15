unit Mercury.Helpers.IPAddressUtils;

interface
uses
  System.Generics.Collections;

type
  T4 = 0..3;
  T8 = 0..7;
  TIPv4ByteArray = array[T4] of Byte;
  TIPv6WordArray = array[T8] of Word;

  TIPv4 = packed record
    case Integer of
      0: (D, C, B, A: Byte);
      1: (Groups: TIPv4ByteArray);
      2: (Value: Cardinal);
  end;

  TIPv6 = packed record
    case Integer of
      0: (H, G, F, E, D, C, B, A: Word);
      1: (Groups: TIPv6WordArray);
  end;

{$SCOPEDENUMS ON}
type
  TConnectionControl = (
    Allow = 0,
    MayRelay = 2,
    AreExemptFromTransactionFiltering = 4,
    AutoEnableSessionLogging = 8,
    Whitelist = 16,
    AreExemptFromMsgSizeRestrictions = 32,
    EnableSSLTLS = 64,
    DisableSSLTLS = 128
  );
  TConnectionControls = set of TConnectionControl;

  TIPv4v6 = record
    case IPIsv4: Boolean of
      True: (IPv4: TIPv4);
      False: (IPv6: TIPv6);
  end;

  TIPRange = record
    IPFrom: TIPv4v6;
    IPTo: TIPv4v6;
    Permissions: TConnectionControls;
    Comments: string;
  end;

function InIPRange(const IP, IPFrom, IPTo: string): Boolean; overload;
function InIPRange(const IP, IPFrom, IPTo: TIPv4): Boolean; overload;
function InIPRange(const IP, IPFrom, IPTo: TIPv6): Boolean; overload;
function InIPRanges(const AIP: string; out VIPRange: TIPRange): Boolean;
function StrToIPv4(const S: string): TIPv4;
function StrToIPv6(const S: string): TIPv6;
function IsV4(const S: string): Boolean;
function IsV6(const S: string): Boolean;
procedure LoadWhiteList(const AList: TList<TIPRange>; const Filename: string);
function Whitelisted(const AIP: string): Boolean;

var
  Whitelist: TList<TIPRange>;

implementation
uses
  System.AnsiStrings, Mercury.Helpers,
  System.Math, System.SysUtils, System.StrUtils, System.Classes;

const
  SInvalidIPv4Value = '''%s'' is not a valid IPv4 address';
  SInvalidIPv6Value = '''%s'' is not a valid IPv6 address';

type
  EIPv4Error = class(EVariantError);
  EIPv6Error = class(EVariantError);

procedure IPv4ErrorFmt(const Message, IPv4AsString: string);
begin
  raise EIPv4Error.Create(Format(Message, [IPv4AsString]));
end;

procedure IPv6ErrorFmt(const Message, IPv6AsString: string);
begin
  raise EIPv6Error.Create(Format(Message, [IPv6AsString]));
end;

function IPv4ToStr(const AIPv4: TIPv4): string;
begin
  with AIPv4 do
    Result := Format('%d.%d.%d.%d', [A, B, C, D]);
end;

function StrToIPv4(const S: string): TIPv4;
var
  SIP: string;
  Start: Integer;
  I: T4;
  Index: Integer;
  Count: Integer;
  SGroup: string;
  G: Integer;
begin
  SIP := S + '.';
  Start := 1;
  for I := High(T4) downto Low(T4) do
  begin
    Index := PosEx('.', SIP, Start);
    if Index = 0 then
      IPv4ErrorFmt(SInvalidIPv4Value, S);
    Count := Index - Start + 1;
    SGroup := Copy(SIP, Start, Count - 1);
    if TryStrToInt(SGroup, G) and (G >= Low(Word)) and (G <= High(Word)) then
        Result.Groups[I] := G
      else
        Result.Groups[I] := 0;
    Inc(Start, Count);
  end;
end;

function IPv6ToStr(const AIPv6: TIPv6; const ToLowerCase: Boolean = False): string;
begin
  with AIPv6 do
    Result := Format('%x:%x:%x:%x:%x:%x:%x:%x', [A, B, C, D, E, F, G, H]);
  if ToLowerCase then
    Result := LowerCase(Result);
end;

function StrToIPv6(const S: string): TIPv6;
{ Valid examples for S:
  2001:0db8:85a3:0000:0000:8a2e:0370:7334
  2001:db8:85a3:0:0:8a2e:370:7334
  2001:db8:85a3::8a2e:370:7334
  ::8a2e:370:7334
  2001:db8:85a3::
  ::1
  ::
  ::ffff:c000:280
  ::ffff:192.0.2.128 }
var
  ZeroPos: Integer;
  DotPos: Integer;
  SIP: string;
  Start: Integer;
  Index: Integer;
  Count: Integer;
  SGroup: string;
  G: Integer;

  procedure NormalNotation;
  var
    I: T8;
  begin
    SIP := S + ':';
    Start := 1;
    for I := High(T8) downto Low(T8) do
    begin
      Index := PosEx(':', SIP, Start);
      if Index = 0 then
        IPv6ErrorFmt(SInvalidIPv6Value, S);
      Count := Index - Start + 1;
      SGroup := '$' + Copy(SIP, Start, Count - 1);
      if not TryStrToInt(SGroup, G) or (G > High(Word)) or (G < 0) then
        IPv6ErrorFmt(SInvalidIPv6Value, S);
      Result.Groups[I] := G;
      Inc(Start, Count);
    end;
  end;

  procedure CompressedNotation;
  var
    I: T8;
    A: array of Word;
  begin
    SIP := S + ':';
    Start := 1;
    I := High(T8);
    while Start < ZeroPos do
    begin
      Index := PosEx(':', SIP, Start);
      if Index = 0 then
        IPv6ErrorFmt(SInvalidIPv6Value, S);
      Count := Index - Start + 1;
      SGroup := '$' + Copy(SIP, Start, Count - 1);
      if not TryStrToInt(SGroup, G) or (G > High(Word)) or (G < 0) then
        IPv6ErrorFmt(SInvalidIPv6Value, S);
      Result.Groups[I] := G;
      Inc(Start, Count);
      Dec(I);
    end;
    FillChar(Result.H, (I + 1) * SizeOf(Word), 0);
    if ZeroPos < (Length(S) - 1) then
    begin
      SetLength(A, I + 1);
      Start := ZeroPos + 2;
      repeat
        Index := PosEx(':', SIP, Start);
        if Index > 0 then
        begin
          Count := Index - Start + 1;
          SGroup := '$' + Copy(SIP, Start, Count - 1);
          if not TryStrToInt(SGroup, G) or (G > High(Word)) or (G < 0) then
            IPv6ErrorFmt(SInvalidIPv6Value, S);
          A[I] := G;
          Inc(Start, Count);
          Dec(I);
        end;
      until Index = 0;
      Inc(I);
      Count := Length(A) - I;
      Move(A[I], Result.H, Count * SizeOf(Word));
    end;
  end;

  procedure DottedQuadNotation;
  var
    I: T4;
  begin
    if UpperCase(Copy(S, ZeroPos + 2, 4)) <> 'FFFF' then
      IPv6ErrorFmt(SInvalidIPv6Value, S);
    FillChar(Result.E, 5 * SizeOf(Word), 0);
    Result.F := $FFFF;
    SIP := S + '.';
    Start := ZeroPos + 7;
    for I := Low(T4) to High(T4) do
    begin
      Index := PosEx('.', SIP, Start);
      if Index = 0 then
        IPv6ErrorFmt(SInvalidIPv6Value, S);
      Count := Index - Start + 1;
      SGroup := Copy(SIP, Start, Count - 1);
      if not TryStrToInt(SGroup, G) or (G > High(Byte)) or (G < 0) then
        IPv6ErrorFmt(SInvalidIPv6Value, S);
      case I of
        0: Result.G := G shl 8;
        1: Inc(Result.G, G);
        2: Result.H := G shl 8;
        3: Inc(Result.H, G);
      end;
      Inc(Start, Count);
    end;
  end;

begin
  ZeroPos := Pos('::', S);
  if ZeroPos = 0 then
    NormalNotation
  else
  begin
    DotPos := Pos('.', S);
    if DotPos = 0 then
      CompressedNotation
    else
      DottedQuadNotation;
  end;
end;

function IPRangeV4(const IP, IPFrom, IPTo: TIPv4): Boolean;
begin
  Result := InRange(IP.D, IPFrom.D, IPTo.D) and
    InRange(IP.C, IPFrom.C, IPTo.C) and
    InRange(IP.B, IPFrom.B, IPTo.B) and
    InRange(IP.A, IPFrom.A, IPTo.A);
end;

function IPRangeV6(const IP, IPFrom, IPTo: TIPv6): Boolean;
begin
  Result := InRange(IP.H, IPFrom.H, IPTo.H) and
    InRange(IP.G, IPFrom.G, IPTo.G) and
    InRange(IP.F, IPFrom.F, IPTo.F) and
    InRange(IP.E, IPFrom.E, IPTo.E) and
    InRange(IP.D, IPFrom.D, IPTo.D) and
    InRange(IP.C, IPFrom.C, IPTo.C) and
    InRange(IP.B, IPFrom.B, IPTo.B) and
    InRange(IP.A, IPFrom.A, IPTo.A);
end;

function IsV4(const S: string): Boolean;
begin
  Result := Pos('.', S) > 1;
end;

function IsV6(const S: string): Boolean;
begin
  Result := Pos(':', S) > 0;
end;

function IPRange(const IP, IPFrom, IPTo: string): Boolean;
var
  IP4, FR4, TO4: TIPv4;
  IP6, FR6, TO6: TIPv6;

begin
  if (IsV6(IP)) and (IsV6(IPFrom)) and (IsV6(IPTo)) then
    begin
      IP6 := StrToIPv6(IP);
      FR6 := StrToIPv6(IPFrom);
      TO6 := StrToIPv6(IPTo);
      Result := IPRangeV6(IP6, FR6, TO6);
    end else
  if (IsV4(IP)) and (IsV4(IPFrom)) and (IsV4(IPTo)) then
    begin
      IP4 := StrToIPv4(IP);
      FR4 := StrToIPv4(IPFrom);
      TO4 := StrToIPv4(IPTo);
      Result := IPRangeV4(IP4, FR4, TO4);
    end else
    begin
      raise Exception.Create('Invalid IP Address Input');
    end;
end;

function InIPRange(const IP, IPFrom, IPTo: string): Boolean;
begin
  Result := IPRange(IP, IPFrom, IPTo);
end;

function InIPRange(const IP, IPFrom, IPTo: TIPv4): Boolean;
begin
  Result := IPRangeV4(IP, IPFrom, IPTo);
end;

function InIPRange(const IP, IPFrom, IPTo: TIPv6): Boolean;
begin
  Result := IPRangeV6(IP, IPFrom, IPTo);
end;

function InIPRanges(const AIP: string; out VIPRange: TIPRange): Boolean;
var
  LIPv4: TIPv4;
  LIPv6: TIPv6;
  IsIPv4: Boolean;
begin
  Result := False;
  if not Assigned(Whitelist) then
    Exit;
  try
    IsIPv4 := IsV4(AIP);
    if IsIPv4 then
      LIPv4 := StrToIPv4(AIP) else
      LIPv6 := StrToIPv6(AIP);
    Initialize(VIPRange);
    for var LIPRange in Whitelist do
      begin
        case IsIPv4 of
          True:  begin
                   if LIPRange.IPFrom.IPIsv4 then
                     begin
                       Result := InIPRange(LIPv4, LIPRange.IPFrom.IPv4, LIPRange.IPTo.IPv4);
                       if Result then
                         begin
                           VIPRange := LIPRange;
                           Break;
                         end;
                     end;
                 end;
          False: begin
                   if not LIPRange.IPFrom.IPIsv4 then
                     begin
                       Result := InIPRange(LIPv6, LIPRange.IPFrom.IPv6, LIPRange.IPTo.IPv6);
                       if Result then
                         begin
                           VIPRange := LIPRange;
                           Break;
                         end;
                     end;
                 end;
        end;
      end;
  except
    // Not an IP, but a hostname
  end;
end;

procedure StrToIP(const SIP: string; var Addr: TIPv4v6);
begin
  case IsV4(SIP) of
    True: begin
            Addr.IPIsv4 := True;
            Addr.IPv4 := StrToIPv4(SIP);
          end;
    False: begin
            Addr.IPIsv4 := False;
            Addr.IPv6 := StrToIPv6(SIP);
           end;
  end;
end;

procedure LoadWhiteList(const AList: TList<TIPRange>; const Filename: string);
var
  LList: TStringList;
  LIndex, LIdxColon: Integer;
  Valid: Boolean;
  LChar: Char;
begin
  LList := TStringList.Create;
  try
    LList.LoadFromFile(Filename);
    var LLineNo := 0;
    for var Line in LList do
      begin
        Inc(LLineNo);
        Valid := True;
        var LIPRange: TIPRange;
        try
          try
            LChar := '.';
            var LLine := Line;
            var LIdxSpace := Pos(' ', LLine);

            if LLine = '' then
              Continue;

            // Each line looks like the following
            // xx IPFrom[ Optional IPTo][; optional comments]

            // parse permissions
            var SPermission := Copy(LLine, 1, LIdxSpace-1);
            var NPermission := StrToInt(SPermission);
            var LPermission: TConnectionControls := [];
            case NPermission of
              0: LPermission := LPermission + [TConnectionControl.Allow];
              1: LPermission := LPermission + []; // nothing, 1 is Disallow
            else
              for var TPermission in [TConnectionControl.MayRelay, TConnectionControl.AreExemptFromTransactionFiltering,
               TConnectionControl.AutoEnableSessionLogging, TConnectionControl.Whitelist,
               TConnectionControl.AreExemptFromMsgSizeRestrictions, TConnectionControl.EnableSSLTLS,
               TConnectionControl.DisableSSLTLS] do
                begin
                  if NPermission and Ord(TPermission) = Ord(TPermission) then
                    LPermission := LPermission + [TPermission];
                end;
            end;
            LIPRange.Permissions := LPermission;

            Delete(LLine, 1, LIdxSpace);
            LIdxSpace := Pos(' ', LLine);
            LIdxColon := Pos(';', LLine);
            if (LIdxColon < LIdxSpace) and (LIdxColon > 0) then
              LIndex := LIdxColon else
              LIndex := LIdxSpace;
            if LIdxSpace <= 0 then
              LIndex := Length(LLine)+1;
            if LIndex < Length(LLine) then
              LChar := LLine[LIndex];
            var TempIP := Copy(LLine, 1, LIndex-1);
            StrToIP(TempIP, LIPRange.IPFrom);

            Delete(LLine, 1, LIndex);
            // this could be a comment, not an IP address, or it could be empty
            if LChar = ';' then
              begin
                // It's a comment
                LIPRange.IPTo := LIPRange.IPFrom;
                LIPRange.Comments := Copy(LLine, 1, Length(LLine));
              end else
              begin
                LIdxSpace := Pos(' ', LLine);
                LIdxColon := Pos(';', LLine);
                var LCommentsAvailable := LIdxSpace > 0;
                if LIdxSpace <= 0 then
                  LIndex := Length(LLine)+1;
                if LIdxColon > 0 then
                  LIndex := LIdxColon;
                TempIP := Copy(LLine, 1, LIndex-1);
                if TempIP = '' then
                  begin
                    LIPRange.IPTo := LIPRange.IPFrom;
                    Continue;
                  end;
                StrToIP(TempIP, LIPRange.IPTo);

                Delete(LLine, 1, LIdxSpace);
                if LCommentsAvailable then
                  begin
                    if Pos(' ', LLine) = 1 then
                      Delete(LLine, 1, 1);
                    LIPRange.Comments := Copy(LLine, 1, Length(LLine));
                  end;
              end;
          except
            Log(System.AnsiStrings.Format('Unable to parse line %.3d: "%s"', [LLineNo, Line]));
            Valid := False;
          end;
        finally
          if Valid then
            begin
              AList.Add(LIPRange);
            end;
        end;
      end;
// LIPRange can cause leaks
  finally
    LList.Free;
  end;
end;

function Whitelisted(const AIP: string): Boolean;
var
  LIPRange: TIPRange;
begin
  Result := InIPRanges(AIP, LIPRange) and (TConnectionControl.Whitelist in LIPRange.Permissions);
end;

end.
