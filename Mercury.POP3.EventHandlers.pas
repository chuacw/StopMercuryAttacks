unit Mercury.POP3.EventHandlers;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface
uses
  Mercury.POP3.Events, Mercury.Daemon;

function startup(m: PMercuryFuncPtrs; var flags: UINT_32; Name,
  param: PAnsiChar): Smallint; cdecl; export;

function closedown(m: PMercuryFuncPtrs; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;

implementation
uses
  System.SysUtils, System.Generics.Collections, System.DateUtils,
  System.AnsiStrings, Mercury.Helpers;

const
  MinConnectTime = 70;

type
  TIPAddress = AnsiString;

var
  LastConnectionTime: TDictionary<TIPAddress, TDateTime> = nil;
  LastUserPassCount: TDictionary<TIPAddress, Integer> = nil;

///<summary>Blacklist a connection if its LastConnection time is &lt; 70 seconds.
///<param name="module">Module ID</param>
///<param name="event">Event ID</param>
///<param name="edata">Points to a PMPEventBuf.</param>
///<param name="cdata">custom data provided during registration of this handler.</param>
///</summary>
function POP3EventHandler(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  pms: PMPEventBuf;
  LastConnectedOn: TDateTime;
begin
  Result := 1; // Non-zero to indicate success!
  try
    pms := PMPEventBuf(EventData);
    IPAddress := pms.client;

    if Pos(AnsiString('192.168'), IPAddress)>=0 then
      Exit;

    if LastConnectionTime.ContainsKey(IPAddress) then
      begin
        LastConnectedOn := LastConnectionTime[IPAddress];
        // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn));
        ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn)), IPAddress);
        if WithinPastSeconds(Now, LastConnectedOn, MinConnectTime) then
          begin
            Log(Format('Connection %s blacklisted.', [IPAddress]));
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

///<summary> Increases user account associated with IP address when it
/// sends a USER or a PASS command
/// Since the count is reset when the login is successful,
/// should the count be > 2, that means an authentication pass failed,
/// and the IP address should be blacklisted
///<param name="module">Module ID</param>
///<param name="event">Event ID</param>
///<param name="edata">Points to a PMPEventBuf</param>
///<param name="cdata">Any data you would like Mercury to pass you when it sends
/// you an event notification. Anything you supply here will be passed
/// back to you in the "cdata" parameter for your event handler. You
/// might, for instance, wish to pass your MI_INTERFACE pointer in this
/// field, to make it available to your event handler process.</param>
///</summary>
function POP3CommandHandler(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
var
  IPAddress, Command: AnsiString;
  PMSEvent: PMPEventBuf;
  LastCount: Integer;
  IsUserPass: Boolean;
begin
  Result := 0; // Continue to next handler...
  try
    PMSEvent := PMPEventBuf(EventData);
    if not Assigned(PMSEvent) then
      Exit;
    IPAddress := PMSEvent.client;
    Command := AnsiUpperCase(PMSEvent.inbuf);
    Log(Format('Checking connection %s for USER/PASS', [IPAddress]));
    IsUserPass := (AnsiPos(AnsiString('USER'), Command) <> 0) or
      (AnsiPos(AnsiString('PASS'), Command) <> 0);
    if not IsUserPass then
      Exit;
    if LastUserPassCount.ContainsKey(IPAddress) then
      begin
        LastCount := LastUserPassCount[IPAddress];
        Inc(LastCount);
        // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn));
        if LastCount>2 then
          begin
            Log(Format('Connection %s blacklisted for multiple USER/PASS.', [IPAddress]));
            LastUserPassCount.Remove(IPAddress);
            Exit(-3);   // -3 to blacklist!
          end;
      end else
      begin
        // LDateTime := 'never';
        LastCount := 1;
        ShowLastConnectedTime('never', IPAddress);
      end;
    LastUserPassCount.AddOrSetValue(IPAddress, LastCount);
  except
    on E: Exception do
      begin
        Log(E.Message);
      end;
  end;
end;

///<summary>Reset user pass count when login/auth is successful
///</summary>
function POP3ResetUserPassCount(ModuleID: UINT_32; EventID: UINT_32;
  EventData: Pointer; CustomData: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  PMSEvent: PMPEventBuf;
begin
  Result := 0; // Continue to next handler...
  PMSEvent := PMPEventBuf(EventData);
  if not Assigned(PMSEvent) then
    Exit;
  IPAddress := PMSEvent.client;
  if LastUserPassCount.ContainsKey(IPAddress) then
    begin
      Log(Format('Reset USER/PASS count for %s', [IPAddress]));
      LastUserPassCount.Remove(IPAddress);
    end;
end;

function RegisterPOP3EventHandler(Event: UINT_32; EProc: EVENTPROC; CustomData: Pointer): INT_32; inline;
begin
  if not Assigned(MercuryFuncPtrs.RegisterEventHandler) then
    Exit(0);
  Result := MercuryFuncPtrs.RegisterEventHandler(MMI_MERCURYP, Event, EProc, CustomData);
end;

function startup(m: PMercuryFuncPtrs; var flags: UINT_32; Name, Param: PAnsiChar): Smallint;
var
  Text: string;
begin
  Flags := 0;
  MercuryFuncPtrs := m^; // Copy the structure, not the pointer, as the data at the pointer will be released
  ModuleName := name;

  if RegisterPOP3EventHandler(MPEVT_CONNECT2, @POP3EventHandler, nil) = 0 then
    Text := 'Failed to register Connect Handler' else
    begin
      Text := Format('Connect Handler registered successfully, Min: %d', [MinConnectTime]);
      LastConnectionTime := TDictionary<TIPAddress, TDateTime>.Create;
    end;
  Log(Text);

  if RegisterPOP3EventHandler(MPEVT_COMMAND, @POP3CommandHandler, nil) = 0 then
    Text := 'Failed to register Command Handler' else
    begin
      Text := 'Command Handler registered successfully';
      LastUserPassCount := TDictionary<TIPAddress, Integer>.Create;
    end;
  Log(Text);

  if RegisterPOP3EventHandler(MPEVT_LOGIN, @POP3ResetUserPassCount, nil) = 0 then
    Text := 'Failed to register ResetUserPass Handler' else
    begin
      Text := 'ResetUserPass Handler registered successfully';
      if not Assigned(LastUserPassCount) then
        LastUserPassCount := TDictionary<TIPAddress, Integer>.Create;
    end;
  Log(Text);

  Result := 1; // Non-zero to indicate success!
end;

procedure Shutdown;
begin
  FreeAndNil(LastUserPassCount);
  FreeAndNil(LastConnectionTime);
  LastUserPassCount := nil;
  LastConnectionTime := nil;
end;

function closedown(m: PMercuryFuncPtrs; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
begin
  Shutdown;
  Result := 0;
end;

initialization
finalization
  Shutdown;
end.
