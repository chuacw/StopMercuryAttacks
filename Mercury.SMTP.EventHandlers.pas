unit Mercury.SMTP.EventHandlers;
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{.$STRONGLINKTYPES OFF}
// chuacw
{$WEAKLINKRTTI ON}

interface
uses Mercury.SMTP.Events, Mercury.Daemon;

function startup(m: PM_INTERFACE; var Flags: UINT_32; Name,
  Param: PAnsiChar): Smallint; cdecl; export;

{$IF DEFINED(CLOSEDOWN)}
function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;
{$ENDIF}

implementation
uses System.SysUtils, System.Generics.Collections, System.DateUtils,
  System.Classes, System.AnsiStrings, System.Win.Firewall, System.SyncObjs,
  Mercury.Helpers;

const
  MinConnectTime = 70;
  MinTimeBetweenAuth = 5;

type
  TIPAddress = AnsiString;
  TCommand = AnsiString;

var
  LastAuthTime: TDictionary<TIPAddress, TDateTime> = nil;
  LastConnectionTime: TDictionary<TIPAddress, TDateTime> = nil;
  Blacklist: TStringList;
//  Event: TEvent;

///<param name="module">module which the event is meant for</param>
///<param name="event">ID of event</param>
///<param name="edata">event data</param>
///<param name="cdata">custom data</param>
///<summary>Handles the event for the given module</summary>
function SMTPEventHandler(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  pms: PMSEventBuf;
  LastConnectedOn: TDateTime;
begin
  Result := 1; // Non-zero to indicate success!
  try
    pms := PMSEventBuf(EventData);
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
              if Assigned(Blacklist) then Blacklist.Add(string(IPAddress));
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
var
  IPAddress: AnsiString;
  PMSEvent: PMSEventBuf;
  SHelo, ClientNameOrIP, Greeting, BlacklistedClient: AnsiString;
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
  Log(AnsiString(Format('Checking IP: %s for HELO', [IPAddress])));
  SHelo := PMSEvent.inbuf;
  Greeting := UpperCase(Copy(SHelo, 1, 4));
  if Pos('HELO', string(Greeting))=1 then
    Delete(SHelo, 1, 5) else
  if Pos('EHLO', string(Greeting))=1 then
    Delete(SHelo, 1, 5);
  ClientNameOrIP := AnsiString(string(SHelo).Trim);
  if (Length(ClientNameOrIP)>2) then
    begin
      if ClientNameOrIP[1]='[' then
        Delete(ClientNameOrIP, 1, 1);
      if ClientNameOrIP[Length(ClientNameOrIP)]=']' then
        Delete(ClientNameOrIP, Length(ClientNameOrIP), 1);
    end;
  if EndsText('.pw', ClientNameOrIP) or EndsText('rocks', ClientNameOrIP) then
    begin
      bDoNotSpam := True;
//      goto DoNotSpam;
    end;
// This host name doesn't exists, but sends junk often
  for BlacklistedClient in Blacklist do
    if (BlacklistedClient=ClientNameOrIP) or (Pos(BlacklistedClient, ClientNameOrIP)<>0) then
      begin
        bDoNotSpam := True;
        Break;
      end;
  if bDoNotSpam then
    begin
      DoNotSpam:
      System.AnsiStrings.StrPCopy(PMSEvent^.outbuf, '554 DO NOT SPAM!');
      Log(AnsiString(Format('Blocking %s - %s', [ClientNameOrIP, IPAddress])));
      if Assigned(Blacklist) then
        Blacklist.Add(ClientNameOrIP);
      Exit(-3);
    end;
  IsIP := True;
  for C in ClientNameOrIP do  // Tests only IPv4
    if not CharInSet(C, ['0'..'9', '.']) then
      begin
        IsIP := False;
        Break;
      end;
  if IsIP then
    begin
      Log(AnsiString(Format('HELO with IP detected! Rejecting connection from %s', [IPAddress])));
      if Assigned(Blacklist) then
        Blacklist.Add(ClientNameOrIP);
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

procedure BanIPAddress(const IPAddress: AnsiString);
var
  LFilename, LIPAddress: string;
  LBlacklist: TStringList;
begin
  LIPAddress := IPAddress;
  LFilename := 'C:\MERCURY\DAEMONS\SMTPClientBlacklist.ini';
  LBlacklist := TStringList.Create(dupIgnore, True, False);
  try
    if FileExists(LFilename) then
      LBlacklist.LoadFromFile(LFilename);
    LBlacklist.Add(LIPAddress);
    if Assigned(Blacklist) then
      Blacklist.AddStrings(LBlacklist);
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
  Log(AnsiString(Format('Checking IP: %s for Close/Abort', [IPAddress])));

  if (PMSEvent.flags and MSEF_AUTHENTICATED=0) then
    begin
      LIPAddress := IPAddress;
      if LastAuthTime.ContainsKey(LIPAddress) then
        begin
          Log(Format('%s previously tried AUTH and succeeded. Not banning', [IPAddress]));
          Exit(0);
        end;
      Log(AnsiString(Format('Blacklisting %s', [IPAddress])));
      BanIPAddress(IPAddress);
      Exit(-3); // Blacklist!
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
  Log(AnsiString(Format('Checking IP: %s for COMMAND', [IPAddress])));
  if LastAuthTime.ContainsKey(IPAddress) then
    begin
      LastAuthOn := LastAuthTime[IPAddress];
    end else
    begin
      Log(AnsiString(Format('Adding %s to LastAuth', [IPAddress])));
      LastAuthTime.AddOrSetValue(IPAddress, Now);
    end;
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

  Log(AnsiString(Format('Checking IP: %s for AUTH', [IPAddress])));
  if LastAuthTime.ContainsKey(IPAddress) then
    begin
      LastAuthOn := LastAuthTime[IPAddress];
      // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastAuthOn));
      ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastAuthOn)), IPAddress);
      if WithinPastSeconds(Now, LastAuthOn, MinTimeBetweenAuth) then
        begin
          Log(AnsiString(Format('Connection %s blacklisted for AUTH.', [IPAddress])));
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

function RegisterSMTPEventHandler(Event: UINT_32; EProc: EVENTPROC; CustomData: Pointer): INT_32; inline;
begin
  Result := mi.register_event_handler(MMI_MERCURYS, Event, EProc, CustomData);
end;

//function startup(m: PM_INTERFACE; var Flags: UINT_32; const Name,
//  Param: string): Smallint; // cdecl; export;
function startup(m: PM_INTERFACE; var Flags: UINT_32; Name, Param: PAnsiChar): Smallint;
var
  Text: AnsiString;
  LHost: string;
begin
  try
    mi := m^; // Copy the structure, not the pointer, as the data at the pointer will be released
    ModuleName := Name;

    if RegisterSMTPEventHandler(MSEVT_CONNECT2, @SMTPEventHandler, nil)=0 then
      Text := 'Failed to register SMTP event handler' else
      begin
        Text := AnsiString(Format('registered successfully, Min: %d', [MinConnectTime]));
        LastConnectionTime := TDictionary<TIPAddress, TDateTime>.Create;
      end;
    Log(Text);

    if RegisterSMTPEventHandler(MSEVT_HELO, @SMTPHeloHandler, nil)=0 then
      Text := 'Failed to register HELO event handler' else
      Text := AnsiString('SMTPHelo registered successfully');
    Log(Text);

    if RegisterSMTPEventHandler(MSEVT_AUTH, @SMTPAuthHandler, nil)=0 then
      Text := 'Failed to register AUTH event handler' else
      begin
        Text := AnsiString('SMTPAuth registered successfully');
        LastAuthTime := TDictionary<TIPAddress, TDateTime>.Create;
      end;
    Log(Text);

    if RegisterSMTPEventHandler(MSEVT_COMMAND, @SMTPCommand, nil)=0 then
      Text := 'Failed to register COMMAND event handler' else
      begin
        Text := AnsiString('COMMAND registered successfully');
      end;
    Log(Text);

    if RegisterSMTPEventHandler(MSEVT_CLOSE, @SMTPCloseOrAbort, nil)=0 then
      Text := 'Failed to register CLOSE event handler' else
      begin
        Text := AnsiString('CLOSE registered successfully');
      end;
    Log(Text);

    if RegisterSMTPEventHandler(MSEVT_ABORT, @SMTPCloseOrAbort, nil)=0 then
      Text := 'Failed to register ABORT event handler' else
      begin
        Text := AnsiString('ABORT registered successfully');
      end;

    if Text<>'' then Log(Text);

    for LHost in BlackList do
      Log('Blacklisted: ' + AnsiString(LHost));

    Result := 1; // Non-zero to indicate success!
  except
    on E: Exception do
      begin
        Text := AnsiString(E.Message);
        Log('Unloading: '+Text);
        Result := 0; // Unload!
      end;
  end;
end;

procedure InitializeBlacklist;
var
  LFilename: string;
begin
  LFilename := 'C:\MERCURY\DAEMONS\SMTPBlacklist.ini';
  if FileExists(LFilename) then
    begin
      Blacklist.LoadFromFile(LFilename);
    end else
    begin
      Blacklist.Add('mx8287.dmsmtp.nl');
      Blacklist.Add('bop-edge.bop.org');
      Blacklist.Add('mail.sunburydesign.com');
      BlackList.Add('sailmail.net');
    end;
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
  Blacklist := TStringList.Create(dupIgnore, False, False);
  InitializeBlacklist;
finalization
  LastAuthTime.Free;
  LastConnectionTime.Free;
  Blacklist.Sort;
  Blacklist.SaveToFile('C:\MERCURY\DAEMONS\SMTPBlacklist.ini');
  Blacklist.Free;
end.

