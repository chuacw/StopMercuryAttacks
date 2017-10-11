unit Mercury.SMTP.EventHandlers;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface
uses Mercury.SMTP.Events, Mercury.Daemon;

function startup(AMercuryFuncPtrs: PMercuryFuncPtrs; var Flags: UINT_32; Name,
  Param: PAnsiChar): Smallint; cdecl;

///<summary>Doesn't get called if startup is exported.</summary>
function configure(M: PMercuryFuncPtrs; Name, Param: PAnsiChar): Short; cdecl;

///<summary>Forwards calls to configure in library specified in Daemon_Config's Param.
/// configureforwarder exists in a separate DLL, which forwards to the actual DLL.
/// The configuration section needs to look like the following:
/// [Daemon_Config]
/// Configure StopSMTPAttack...=C:\MERCURY\DAEMONS\Mercury.Daemons.Forwarder.dll;C:\MERCURY\DAEMONS\Mercury.Daemons.StopSMTPAttacks.dll
/// The DLL after the ; is the DLL to load and forward the call to
/// <param name="M">Pointer to M_INTERFACE</param>
/// <param name="Unused">Unused</param>
/// <param name="ForwardToDLL">Points to DLL to forward to</param>
///</summary>
function configureforwarder(M: PMercuryFuncPtrs; Unused, ForwardToDLL: PAnsiChar): Short; cdecl;

function daemon(job: Pointer; M: PMercuryFuncPtrs; Address, Parameter: PAnsiChar): Short; cdecl;

function closedown(m: PMercuryFuncPtrs; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl;

implementation
uses
  SysUtils.GuardUtils, System.SysUtils,
  System.Generics.Collections,
  System.DateUtils, System.Classes, System.AnsiStrings, System.Win.Firewall,
  System.SyncObjs, Mercury.Helpers, VCL.Forms, Winapi.Windows,
  Mercury.SMTP.ConfigureBlacklist, Vcl.Controls;

const
  SMailFrom: AnsiString = 'MAIL FROM';

function EmailOf(const AEmailAddr: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := UpperCase(AEmailAddr);
  if Pos(AnsiString(SMailFrom), Result)=1 then
    begin
      Result := AEmailAddr;  // Remove the results of the UpperCase
      Delete(Result, 1, Length(SMailFrom));
    end;
  I := AnsiPos(AnsiString(':'), Result);
  if I>0 then
    Delete(Result, I, 1);
  I := AnsiPos(AnsiString('<'), Result);
  if I>0 then
    Delete(Result, I, 1);
  I := AnsiPos(AnsiString('>'), Result);
  if I>0 then
    Delete(Result, I, 1);
  Result := Trim(Result);
end;

function IsValidMailFrom(const AMailFrom: AnsiString): Boolean;
var
  LMailFrom: AnsiString;
begin
  LMailFrom := UpperCase(Trim(AMailFrom));
  Result := AnsiPos(SMailFrom, LMailFrom)>0;
end;

function DomainOf(const AEmailAddr: AnsiString): AnsiString;
var
  LAt: Integer;
begin
  LAt := AnsiPos(AnsiString('@'), AEmailAddr);
  if LAt>0 then
    Result := Copy(AEmailAddr, LAt+1, Length(AEmailAddr)-LAt) else
    Result := '';
end;

const
  MinConnectTime = 70;
  MinTimeBetweenAuth = 5;

type
  TIPAddress = AnsiString;
  TCommand = AnsiString;
  THandler = reference to function: INT_32;

  TUniqueValue = record
    U1: Integer;
    U2: string;
  end;

var
  UniqueValue: TUniqueValue;

var
  GStartupCode: Int64;
  LastAuthTime: TDictionary<TIPAddress, TDateTime> = nil;
  LastConnectionTime: TDictionary<TIPAddress, TDateTime> = nil;
  BlacklistDirty: Boolean;
  BlacklistedSender,
  MightBan: TList<AnsiString>; Blacklist: TStringList;
  Handlers: TList<THandler>;
//  Event: TEvent;

procedure CheckAdd(const AList: TStringList; const IPAddress: AnsiString); forward;

///<param name="module">module which the event is meant for</param>
///<param name="event">ID of event</param>
///<param name="edata">event data</param>
///<param name="cdata">custom data</param>
///<summary>Handles the event for the given module</summary>
function SMTPMailFromHandler(ModuleID, EventID: UINT_32;
  EventData, CustomData: Pointer): INT_32; cdecl;
const
  SDoNotSpam: AnsiString = '554 DO NOT SPAM!';
  SInvalidMailFrom: AnsiString = '500 Invalid MAIL FROM!';
var
  LBlockedHost: string;
  LDomain, LBlockedDomainOrHost, LMailFrom, LEmailAddr, LIPOrHost: AnsiString;
  PMSEvent: PMSEventBuf;
  LIsValidMailFrom: Boolean;
begin
  Result := 1; // Non-zero to indicate success!
  try
    PMSEvent := PMSEventBuf(EventData);
    LMailFrom := AnsiString(PMSEvent.inbuf);
    LIsValidMailFrom := IsValidMailFrom(LMailFrom);
    if not LIsValidMailFrom then
      begin
        System.AnsiStrings.StrPCopy(PMSEvent^.outbuf, SInvalidMailFrom);
        Exit(-1);
      end;
    LEmailAddr := EmailOf(LMailFrom);
    LDomain := DomainOf(LEmailAddr);
//    if LEmailAddr.StartsWith('<'
    LIPOrHost := PMSEvent.client;
    Log(System.AnsiStrings.Format('connection from %s', [LIPOrHost]));

// Blacklist email senders such as swe.topform@gmail.com using similar methods to below
//
//    if (AnsiPos('of@', string(LEmailAddr))>0) or
//       (AnsiPos('cha.topform@gmail.com', string(LEmailAddr))>0) then
//      Exit(-3);

  for LBlockedHost in Blacklist do
    begin
      LBlockedDomainOrHost := AnsiString(LBlockedHost);
      if AnsiPos(LBlockedDomainOrHost, LDomain)>0 then
        begin
          System.AnsiStrings.StrPCopy(PMSEvent^.outbuf, SDoNotSpam);
          Log(System.AnsiStrings.Format('Blocked: %s, %s: %s', [LIPOrHost, 'Sender', LEmailAddr]));
          CheckAdd(Blacklist, LIPOrHost);
          Exit(-3);
        end;
    end;

  except
    on E: Exception do
      begin
        Log(E.Message);
      end;
  end;
end;

procedure CheckAdd(const AList: TStringList; const IPAddress: AnsiString);
begin
  if Assigned(AList) and (AList.IndexOf(string(IPAddress))<>-1) then
    begin
      AList.Add(string(IPAddress));
    end;
end;

///<param name="module">module which the event is meant for</param>
///<param name="event">ID of event</param>
///<param name="edata">event data</param>
///<param name="cdata">custom data</param>
///<summary>Handles the event for the given module</summary>
function SMTPEventHandler(ModuleID, EventID: UINT_32;
  EventData, CustomData: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  pms: PMSEventBuf;
  LastConnectedOn: TDateTime;
begin
  Result := 1; // Non-zero to indicate success!
  try
    pms := PMSEventBuf(EventData);
    IPAddress := AnsiString(pms.client);

    Log(System.AnsiStrings.Format('connection from %s', [IPAddress]));

    if AnsiPos(AnsiString('192.168'), IPAddress)>0 then Exit;

      if LastConnectionTime.ContainsKey(IPAddress) then
        begin
          LastConnectedOn := LastConnectionTime[IPAddress];
          // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn));
          ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn)), IPAddress);
          if WithinPastSeconds(Now, LastConnectedOn, MinConnectTime) then
            begin
              Log(System.AnsiStrings.Format('Connection %s blacklisted.', [IPAddress]));
              CheckAdd(Blacklist, IPAddress);
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
        Log(E.Message);
      end;
  end;
end;

/// Reject connections that presents
/// HELO IPaddress
///<param name="ModuleID">module which the event is meant for</param>
///<param name="EventID">ID of event</param>
///<param name="EventData">event data</param>
///<param name="CustomData">custom data</param>
///<summary>Handles the HELO event for the given module, and blocks connections
/// that specifies an IP address in its HELO.</summary>
function SMTPHeloHandler(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
const
  cBlockSMTP: string = 'Block SMTP';
  SHelo: AnsiString = 'HELO';
  SEhlo: AnsiString = 'EHLO';
var
  IPAddress: AnsiString;
  PMSEvent: PMSEventBuf;
  LHelo, LClientNameOrIP, LGreeting, LHeloType: AnsiString;
  LBlacklistedClient: string;
  C: AnsiChar;
{$HINTS OFF}
  IsIP, LFreeRule: Boolean;
//  LFirewall: TWindowsFirewall;
//  LBlockSMTP: TWindowsFirewall.TWindowsFirewallRule;
  LEvent: TEvent;
  bDoNotSpam: Boolean;
label DoNotSpam;
begin
  bDoNotSpam := False;
  LEvent := TEvent.Create(nil, True, False, 'MercurySMTPDump');
  if LEvent.WaitFor(10) = wrSignaled then
    begin
      // Dump the information
    end;
  LEvent.Free;

  Result := 1; // Non-zero to indicate success!

  PMSEvent := PMSEventBuf(EventData);
  IPAddress := AnsiString(PMSEvent.client);

  if AnsiPos(AnsiString('192.168'), IPAddress)>0 then Exit;

  Log(System.AnsiStrings.Format('Checking IP: %s for HELO', [IPAddress]));
  LHelo := PMSEvent.inbuf;
  LGreeting := AnsiUpperCase(Copy(SHelo, 1, 4));
  if AnsiPos(SHelo, LGreeting)=1 then
    begin
      Delete(LHelo, 1, 5);
      LHeloType := SHelo;
    end else
  if AnsiPos(SEhlo, LGreeting)=1 then
    begin
      Delete(LHelo, 1, 5);
      LHeloType := SEhlo;
    end;
  LClientNameOrIP := AnsiString(Trim(SHelo));
  if (Length(LClientNameOrIP)>2) then
    begin
      if LClientNameOrIP[1]='[' then
        Delete(LClientNameOrIP, 1, 1);
      if LClientNameOrIP[Length(LClientNameOrIP)]=']' then
        Delete(LClientNameOrIP, Length(LClientNameOrIP), 1);
    end;
// This host name doesn't exists, but sends junk often
  for LBlacklistedClient in Blacklist do
    if (AnsiString(LBlacklistedClient)=LClientNameOrIP) or
    (AnsiPos(AnsiString(LBlacklistedClient), LClientNameOrIP)>0) then
      begin
        bDoNotSpam := True;
        Break;
      end;
  if bDoNotSpam then
    begin
      DoNotSpam:
      System.AnsiStrings.StrPCopy(PMSEvent^.outbuf, '554 DO NOT SPAM!');
      Log(System.AnsiStrings.Format('Blocked: %s, %s: %s', [LClientNameOrIP, LHeloType, IPAddress]));
      CheckAdd(Blacklist, LClientNameOrIP);
      CheckAdd(Blacklist, IPAddress);
      Exit(-3);
    end;
  IsIP := True;
  for C in LClientNameOrIP do  // Tests only IPv4
    if not CharInSet(C, ['0'..'9', '.']) then
      begin
        IsIP := False;
        Break;
      end;
  if IsIP then
    begin
      Log(System.AnsiStrings.Format('HELO with IP detected! Rejecting connection from %s', [IPAddress]));
      CheckAdd(Blacklist, LClientNameOrIP);
      Result := -3; // Blacklist!
//      LFirewall := TWindowsFirewall.Create;
//      try
//        try
//          LFreeRule := False;
//          if not LFirewall.Rules.FindRule(cBlockSMTP) then
//            begin
//              LFreeRule := True;
//              LBlockSMTP := LFirewall.Rules.CreateRule;
//              LBlockSMTP.Action := Block;
//              LBlockSMTP.AddIP(ClientNameOrIP);
//              LBlockSMTP.Protocol := TCP;
//              LBlockSMTP.Name := cBlockSMTP;
//              LBlockSMTP.LocalPorts := '25';
//            end else
//            begin
//              LBlockSMTP := LFirewall.Rules[cBlockSMTP];
//              LBlockSMTP.AddIP(ClientNameOrIP);
//            end;
//
//          if LFreeRule then
//            LBlockSMTP.Free;
//        except
//
//        end;
//      finally
//        LFirewall.Free;
//      end;
    end;

end;

///<summary>Ensures everyone have a TStringList created with the same options.</summary>
function NewStringList: TStringList;
begin
  Result := TStringList.Create(dupIgnore, True, False);
end;

procedure BanIPAddress(const IPAddress: AnsiString);
var
  LFilename, LIPAddress: string;
  LBlacklist: TStringList;
begin
  LIPAddress := string(IPAddress);
  LFilename := 'C:\MERCURY\DAEMONS\SMTPClientBlacklist.ini';
  LBlacklist := NewStringList;
  try
    if FileExists(LFilename) then
      LBlacklist.LoadFromFile(LFilename);
    LBlacklist.Add(LIPAddress);
//    if Assigned(Blacklist) then
//      Blacklist.AddStrings(LBlacklist);
    LBlacklist.SaveToFile(LFilename);
  finally
    LBlacklist.Free;
  end;
end;

function SMTPCloseOrAbort(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  LIPAddress: string;
  PMSEvent: PMSEventBuf;
  LastAuthOn: TDateTime;
begin
  Result := 0; // Zero to continue through the other event handlers

  PMSEvent := PMSEventBuf(EventData);
  IPAddress := AnsiString(PMSEvent.client);
  Log(System.AnsiStrings.Format('Checking IP: %s for Close/Abort', [IPAddress]));

  if AnsiPos(AnsiString('192.168'), IPAddress)>0 then
    Exit;

  if (PMSEvent.flags and MSEF_AUTHENTICATED<>0) then
    begin
      if LastAuthTime.ContainsKey(IPAddress) then
        begin
          Log(System.AnsiStrings.Format('%s previously tried AUTH and succeeded. Not banning', [IPAddress]));
          Exit(0);
        end;
      Log(System.AnsiStrings.Format('Blacklisting %s', [IPAddress]));
      BanIPAddress(IPAddress);
      Exit(-3); // Blacklist!
    end else
    begin
      Log(System.AnsiStrings.Format('Not authenticated: %s. Might ban?', [IPAddress]));
      MightBan.Add(IPAddress);
    end;

end;

function SMTPCommand(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  PMSEvent: PMSEventBuf;
  LastAuthOn: TDateTime;
begin
  Result := 0; // Zero to continue through the other event handlers

  PMSEvent := PMSEventBuf(EventData);
  IPAddress := AnsiString(PMSEvent.client);
  Log(System.AnsiStrings.Format('Checking IP: %s for COMMAND, Event ID: %d', [IPAddress, EventID]));

  if LastAuthTime.ContainsKey(IPAddress) then
    begin
      LastAuthOn := LastAuthTime[IPAddress];
    end{ else
    begin
      Log(System.AnsiStrings.Format('Adding %s to LastAuth', [IPAddress]));
      LastAuthTime.AddOrSetValue(IPAddress, Now);
    end};
end;

// Rejects AUTH within MinTimeBetweenAuth of each other
function SMTPAuthHandler(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  PMSEvent: PMSEventBuf;
  LastAuthOn: TDateTime;
begin
  Result := 0; // Zero to continue through the other event handlers

  PMSEvent := PMSEventBuf(EventData);
  IPAddress := AnsiString(PMSEvent.client);

  Log(System.AnsiStrings.Format('Checking IP: %s for AUTH', [IPAddress]));
  if LastAuthTime.ContainsKey(IPAddress) then
    begin
      LastAuthOn := LastAuthTime[IPAddress];
      // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastAuthOn));
      ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastAuthOn)), IPAddress);
      if WithinPastSeconds(Now, LastAuthOn, MinTimeBetweenAuth) then
        begin
          Log(System.AnsiStrings.Format('Connection %s blacklisted for AUTH.', [IPAddress]));
          CheckAdd(Blacklist, IPAddress);
          PMSEvent.outbuf[0] := #0;
          Result := -3; // Blacklist!!!
        end;
    end else
    begin
      // LDateTime := 'never';
      ShowLastConnectedTime('never', IPAddress);
    end;
  LastAuthTime.AddOrSetValue(IPAddress, Now);

end;

function RegisterSMTPEventHandler(Event: UINT_32; EProc: EVENTPROC; CustomData: Pointer): INT_32;
begin
  Result := MercuryFuncPtrs.RegisterEventHandler(MMI_MERCURYS, Event, EProc, CustomData);
end;

function configure(M: PMercuryFuncPtrs; Name, Param: PAnsiChar): Short;
var
  LHandle: THandle;
  AWorkingList: TStrings;
  ABlacklistedDomain: string;
  I: Integer;
  LList: TStringList;
begin
  LHandle := THandle(M.get_variable(GV_FRAMEWINDOW));
  try
    if not Assigned(Application) then
      Application := TApplication.Create(nil);
    Application.Handle := LHandle;
// Create forms here

    frmBlacklist := TfrmBlacklist.Create(nil);
    frmBlacklist.Blacklist := Blacklist;
    if frmBlacklist.ShowModal = mrOk then
      begin
        AWorkingList := frmBlacklist.Blacklist;

        LList := TStringList.Create;
        try
        // First, scan for items to add, then add it.
          for I := 0 to AWorkingList.Count-1 do
            begin
              ABlacklistedDomain := AWorkingList[I];
              if Blacklist.IndexOf(ABlacklistedDomain) = -1 then
                begin
                  Blacklist.Add(ABlacklistedDomain);
                  Log('Added: ' + ABlacklistedDomain);
                  BlacklistDirty := True;
                end;
            end;

        // Now, scan for items to remove
          for I := 0 to BlackList.Count-1 do
            begin
              ABlacklistedDomain := Blacklist[I];
              if AWorkingList.IndexOf(ABlacklistedDomain) = -1 then
                LList.Add(ABlacklistedDomain);
            end;
          for ABlacklistedDomain in LList do
            begin
              I := Blacklist.IndexOf(ABlacklistedDomain);
              if I <> -1 then
                begin
                  Blacklist.Delete(I);
                  Log('Removed: ' + ABlacklistedDomain);
                  BlacklistDirty := True;
                end;
            end;
        finally
          LList.Free;
        end;
      end;
    frmBlacklist.Free;

    Result := 0; // unused
  finally
  end;
end;

function configureforwarder(M: PMercuryFuncPtrs; Unused, ForwardToDLL: PAnsiChar): Short; cdecl;
var
  LHandle: THandle;
  LConfigure: TConfigure;
  LibName: string;
begin
  LibName := string(ForwardToDLL);
  LHandle     := LoadLibrary(PChar(LibName));
  if LHandle = 0 then Exit(0);
  LConfigure  := GetProcAddress(LHandle, 'configure');
  if @LConfigure = nil then Exit(0);
  Result := LConfigure(M, Unused, ForwardToDLL);
  if LHandle <> 0 then
    FreeLibrary(LHandle);
end;

function daemon(job: Pointer; M: PMercuryFuncPtrs; Address, Parameter: PAnsiChar): Short; cdecl; export;
begin
  Result := 0;
end;

//function startup(m: PMercuryFuncPtrs; var Flags: UINT_32; const Name,
//  Param: string): Smallint; // cdecl; export;
function startup(AMercuryFuncPtrs: PMercuryFuncPtrs; var Flags: UINT_32; Name, Param: PAnsiChar): Smallint;
var
  LSBFailed, LSBSucceeded: TStringBuilder;

  procedure AppendComma;
  begin
    if (LSBFailed.Length<>0) and (LSBFailed.Chars[LSBFailed.Length-1]<>',') then
      LSBFailed.Append(',');
    if (LSBSucceeded.Length<>0) and (LSBSucceeded.Chars[LSBSucceeded.Length-1]<>',') then
      LSBSucceeded.Append(',');
  end;

var
  Guard: TGuard;
  Text: string;
  LHost: string;
  LHandler: THandler;
begin
  GStartupCode := $11223344;
  Flags := 0;
  Guard.Assign(LSBFailed, TStringBuilder.Create);
  Guard.Assign(LSBSucceeded, TStringBuilder.Create);
  try
    MercuryFuncPtrs := AMercuryFuncPtrs^; // Copy the structure, not the pointer, as the data at the pointer will be released
    ModuleName := Name;

    if Assigned(Handlers) then
      for LHandler in Handlers do
        begin
          try
            LHandler();
          except
            on E: Exception do
              Log('Exception: ' + E.Message);
          end;
        end;

    if RegisterSMTPEventHandler(MSEVT_MAIL, @SMTPMailFromHandler, nil)=0 then
      LSBFailed.Append('SMTP MAIL') else
      begin
//        Text := System.AnsiStrings.Format('registered successfully, Min: %d', [MinConnectTime]);
        LSBSucceeded.Append('SMTP MAIL');
        if LastConnectionTime = nil then
          LastConnectionTime := TDictionary<TIPAddress, TDateTime>.Create;
      end;

    AppendComma;
    if RegisterSMTPEventHandler(MSEVT_CONNECT2, @SMTPEventHandler, nil)=0 then
      LSBFailed.Append('Connect') else
      begin
//        Text := System.AnsiStrings.Format('registered successfully, Min: %d', [MinConnectTime]);
        LSBSucceeded.Append('Connect');
        if LastConnectionTime = nil then
          LastConnectionTime := TDictionary<TIPAddress, TDateTime>.Create;
      end;

    AppendComma;
    if RegisterSMTPEventHandler(MSEVT_HELO, @SMTPHeloHandler, nil)=0 then
      LSBFailed.Append('HELO') else
      LSBSucceeded.Append('SMTPHelo');

    AppendComma;
    if RegisterSMTPEventHandler(MSEVT_AUTH, @SMTPAuthHandler, nil)=0 then
      LSBFailed.Append('AUTH') else
      begin
        LSBSucceeded.Append('AUTH');
        if LastAuthTime = nil then
          LastAuthTime := TDictionary<TIPAddress, TDateTime>.Create;
      end;

    AppendComma;
    if RegisterSMTPEventHandler(MSEVT_COMMAND, @SMTPCommand, nil)=0 then
      LSBFailed.Append('COMMAND') else
      LSBSucceeded.Append('COMMAND');

    AppendComma;
    if RegisterSMTPEventHandler(MSEVT_CLOSE, @SMTPCloseOrAbort, nil)=0 then
      LSBFailed.Append('CLOSE') else
      LSBSucceeded.Append('CLOSE');

    AppendComma;
    if RegisterSMTPEventHandler(MSEVT_ABORT, @SMTPCloseOrAbort, nil)=0 then
      LSBFailed.Append('ABORT') else
      LSBSucceeded.Append('ABORT');

    if LSBFailed.Length>0 then
      Log('Failed: '+LSBFailed.ToString);
    if LSBSucceeded.Length>0 then
      Log('Succeeded: '+LSBSucceeded.ToString);

    for LHost in BlackList do
      Log('Blacklisted: ' + string(LHost));

    Result := 1; // Non-zero to indicate success!
  except
    on E: Exception do
      begin
        Log('Unloading: '+E.Message);
        Result := 0; // Unload!
      end;
  end;
end;

procedure SaveBlackList(const AList: TStringList; const Filename: string);
var
  F: TextFile;
  Line: AnsiString;
begin
  if BlacklistDirty then
    AList.SaveToFile(Filename);
//  AssignFile(F, Filename);
//  Rewrite(F);
//  for Line in AList do
//    WriteLn(F, Line);
//  CloseFile(F);
end;

procedure LoadBlackList(const AList: TStringList; const Filename: string);
var
  F: TextFile;
  Line: AnsiString;
  Backup: TStringList;
begin
  Backup := NewStringList;
  try
    Backup.AddStrings(AList);
    AList.LoadFromFile(Filename);
    AList.AddStrings(Backup);
  finally
    Backup.Free;
  end;
//  AssignFile(F, Filename);
//  Reset(F);
//  while not eof(F) do
//    begin
//      ReadLn(F, Line);
//      if not (AList.IndexOf(Line)=-1) then
//        AList.Add(Line);
//    end;
//  CloseFile(F);
end;

procedure InitializeBlacklist;
var
  LFilename: string;
begin
  LFilename := 'C:\MERCURY\DAEMONS\SMTPBlacklist.ini';
  if FileExists(LFilename) then
    begin
      LoadBlackList(Blacklist, LFilename);
      Blacklist.Sort;
    end else
    begin
      Blacklist.Add('mx8287.dmsmtp.nl');
      Blacklist.Add('bop-edge.bop.org');
      Blacklist.Add('mail.sunburydesign.com');
      BlackList.Add('sailmail.net');
    end;
end;

var
  LFreed: Boolean;

procedure Shutdown;
begin
  if not LFreed then
    begin
      LastAuthTime.Free;
      LastConnectionTime.Free;
      Blacklist.Sort;
      SaveBlackList(Blacklist, 'C:\MERCURY\DAEMONS\SMTPBlacklist.ini');
      Blacklist.Free;
      MightBan.Free;
      LFreed := True;
    end;
end;

function closedown(m: PMercuryFuncPtrs; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
begin
  Shutdown;
  Result := 0;
end;

initialization
  LFreed := False;
  Blacklist := NewStringList;
  MightBan := TList<AnsiString>.Create;
  InitializeBlacklist;
finalization
  Shutdown;
end.

