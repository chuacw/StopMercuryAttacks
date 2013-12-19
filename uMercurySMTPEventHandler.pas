unit uMercurySMTPEventHandler;
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{.$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

interface
uses MSEvent, daemon;

function startup(m: PM_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;

{$IF DEFINED(CLOSEDOWN)}
function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;
{$ENDIF}

implementation
uses System.SysUtils, System.Generics.Collections, System.DateUtils;

const
  MinConnectTime = 70;
  MinTimeBetweenAuth = 5;

type
  TIPAddress = AnsiString;
  TCommand = AnsiString;

var
  ModuleName: AnsiString = '';
  mi: M_INTERFACE;
  LastAuthTime: TDictionary<TIPAddress, TDateTime> = nil;
  LastConnectionTime: TDictionary<TIPAddress, TDateTime> = nil;

procedure Log(const LogMsg: AnsiString);
var
  LText: AnsiString;
begin
  LText := AnsiString(Format('%s: %s', [ModuleName, LogMsg]));
  mi.logstring(19400, LOG_NORMAL, PAnsiChar(LText));
end;

procedure ShowLastConnectedTime(const LDateTime, IPAddress: AnsiString);
var
  Text: AnsiString;
begin
  Text := AnsiString(Format('%s last connection: %s.', [IPAddress, LDateTime]));
  Log(Text);
end;

function SMTPEventHandler(module: UINT_32; event: UINT_32;
  edata: Pointer; cdata: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  pms: PMSEventBuf;
  LastConnectedOn: TDateTime;
begin
  Result := 1; // Non-zero to indicate success!
  try
    pms := PMSEventBuf(edata);
    IPAddress := AnsiString(pms.client);

    Log(AnsiString(Format('connection from %s', [IPAddress])));

      if LastConnectionTime.ContainsKey(IPAddress) then
        begin
          LastConnectedOn := LastConnectionTime[IPAddress];
          // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn));
          ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn)), IPAddress);
          if WithinPastSeconds(Now, LastConnectedOn, MinConnectTime) then
            begin
              Log(AnsiString(Format('Connection %s blacklisted.', [IPAddress])));
              pms.outbuf[0] := #0;
              Result := -3; // Blacklist!!!
            end;

        end else
        begin
          // LDateTime := 'never';
          ShowLastConnectedTime('never', IPAddress);
        end;
      LastConnectionTime.AddOrSetValue(IPAddress, Now);
  except
    on E: Exception do
      begin
        Log(AnsiString(E.Message));
      end;
  end;
end;

/// Reject connections that presents
/// HELO IPaddress
function SMTPHeloHandler(module: UINT_32; event: UINT_32;
  edata: Pointer; cdata: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  pms: PMSEventBuf;
  SHelo: AnsiString;
  C: AnsiChar;
  IsIP: Boolean;
begin
  Result := 1; // Non-zero to indicate success!

  pms := PMSEventBuf(edata);
  IPAddress := AnsiString(pms.client);
  Log(AnsiString(Format('Checking IP: %s for HELO', [IPAddress])));
  SHelo := pms.inbuf;
  if Pos('HELO', string(SHelo))=1 then
    Delete(SHelo, 1, 5) else
  if Pos('EHLO', string(SHelo))=1 then
    Delete(SHelo, 1, 5);
  SHelo := AnsiString(string(SHelo).Trim);
  IsIP := True;
  for C in SHelo do
    if not CharInSet(C, ['0'..'9', '.']) then
      begin
        IsIP := False;
        Break;
      end;
  if IsIP then
    begin
      Log(AnsiString(Format('HELO with IP detected! Rejecting connection from %s', [IPAddress])));
      Result := -3; // Blacklist!
    end;

end;

// Rejects AUTH within MinTimeBetweenAuth of each other
function SMTPAuthHandler(module: UINT_32; event: UINT_32;
  edata: Pointer; cdata: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  pms: PMSEventBuf;
  LastAuthOn: TDateTime;
begin
  Result := 0; // Zero to continue through the other event handlers

  pms := PMSEventBuf(edata);
  IPAddress := AnsiString(pms.client);
  Log(AnsiString(Format('Checking IP: %s for AUTH', [IPAddress])));
  if LastAuthTime.ContainsKey(IPAddress) then
    begin
      LastAuthOn := LastAuthTime[IPAddress];
      // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastAuthOn));
      ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastAuthOn)), IPAddress);
      if WithinPastSeconds(Now, LastAuthOn, MinTimeBetweenAuth) then
        begin
          Log(AnsiString(Format('Connection %s blacklisted for AUTH.', [IPAddress])));
          pms.outbuf[0] := #0;
          Result := -3; // Blacklist!!!
        end;
    end else
    begin
      // LDateTime := 'never';
      ShowLastConnectedTime('never', IPAddress);
    end;
  LastAuthTime.AddOrSetValue(IPAddress, Now);

end;


function startup(m: PM_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
var
  Text: AnsiString;
begin
  mi := m^; // Copy the structure, not the pointer, as the data at the pointer will be released
  ModuleName := name;

  if m.register_event_handler(MMI_MERCURYS, MSEVT_CONNECT, @SMTPEventHandler, nil)=0 then
    Text := 'Failed to register SMTP event handler' else
    begin
      Text := AnsiString(Format('registered successfully, Min: %d', [MinConnectTime]));
      LastConnectionTime := TDictionary<TIPAddress, TDateTime>.Create;
    end;
  Log(Text);

  if m.register_event_handler(MMI_MERCURYS, MSEVT_HELO, @SMTPHeloHandler, nil)=0 then
    Text := 'Failed to register HELO event handler' else
    Text := AnsiString('SMTPHelo registered successfully');
  Log(Text);

  if m.register_event_handler(MMI_MERCURYS, MSEVT_AUTH, @SMTPAuthHandler, nil)=0 then
    Text := 'Failed to register AUTH event handler' else
    begin
      Text := AnsiString('SMTPAuth registered successfully');
      LastAuthTime := TDictionary<TIPAddress, TDateTime>.Create;
    end;
  Log(Text);

  Result := 1; // Non-zero to indicate success!
end;

{$IF DEFINED(CLOSEDOWN)}
function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
begin
  FreeAndNil(LastAuthTime);
  FreeAndNil(LastConnectionTime);
end;
{$ENDIF}

initialization
finalization
  LastAuthTime.Free;
  LastConnectionTime.Free;
end.

