unit uMercuryPOP3EventHandler;
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{.$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

interface
uses MPEvent, daemon;

function startup(m: PM_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;

{$IF DEFINED(CLOSEDOWN)}
function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;
{$ENDIF}

implementation
uses System.SysUtils, System.Generics.Collections, System.DateUtils, System.AnsiStrings;

const
  MinConnectTime = 70;
type
  TIPAddress = AnsiString;
var
  ModuleName: AnsiString;
  mi: M_INTERFACE;
  LastConnectionTime: TDictionary<TIPAddress, TDateTime>;
  LastUserPassCount: TDictionary<TIPAddress, Integer>;

procedure Log(const Text: AnsiString);
begin
  mi.logstring(19400, LOG_NORMAL, PAnsiChar(Text));
end;

procedure ShowLastConnectedTime(const LDateTime, IPAddress: AnsiString);
var
  Text: AnsiString;
begin
  Text := AnsiString(Format('%s: %s last connection: %s.', [ModuleName, IPAddress, LDateTime]));
  Log(Text);
end;

function POP3EventHandler(module: UINT_32; event: UINT_32;
  edata: Pointer; cdata: Pointer): INT_32; cdecl;

var
  IPAddress: AnsiString;
  pms: PMPEventBuf;
  LastConnectedOn: TDateTime;
begin
  Result := 1; // Non-zero to indicate success!
  try
    pms := PMPEventBuf(edata);
    IPAddress := pms.client;
    if LastConnectionTime.ContainsKey(IPAddress) then
      begin
        LastConnectedOn := LastConnectionTime[IPAddress];
        // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn));
        ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn)), IPAddress);
        if WithinPastSeconds(Now, LastConnectedOn, MinConnectTime) then
          begin
            Log(AnsiString(Format('%s: Connection %s blacklisted.', [ModuleName, IPAddress])));
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

/// Increases user account associated with IP address when it
/// sends a USER or a PASS command
/// Since the count is reset when the login is successful,
/// should the count be > 2, that means an authentication pass failed,
/// and the IP address should be blacklisted
function POP3CommandHandler(module: UINT_32; event: UINT_32;
  edata: Pointer; cdata: Pointer): INT_32; cdecl;
var
  IPAddress, Command: AnsiString;
  pms: PMPEventBuf;
  LastCount: Integer;
  IsUserPass: Boolean;
begin
  Result := 0; // Continue to next handler...
  try
    pms := PMPEventBuf(edata);
    IPAddress := pms.client;
    Command := AnsiUpperCase(pms.inbuf);
    Log(AnsiString(Format('%s: Checking connection %s for USER/PASS', [ModuleName, IPAddress])));
    IsUserPass := (AnsiPos(AnsiString('USER'), Command)<>0) or
      (AnsiPos(AnsiString('PASS'), Command)<>0);
    if not IsUserPass then Exit;
    IPAddress := pms.client;
    if LastUserPassCount.ContainsKey(IPAddress) then
      begin
        LastCount := LastUserPassCount[IPAddress];
        Inc(LastCount);
        // LDateTime := AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn));
        if LastCount>2 then
          begin
            Log(AnsiString(Format('%s: Connection %s blacklisted for multiple USER/PASS.', [ModuleName, IPAddress])));
            LastUserPassCount.Remove(IPAddress);
            Exit(-3);
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
        Log(AnsiString(E.Message));
      end;
  end;
end;

// Reset user pass count when login/auth is successful
function POP3ResetUserPassCount(module: UINT_32; event: UINT_32;
  edata: Pointer; cdata: Pointer): INT_32; cdecl;
var
  IPAddress: AnsiString;
  pms: PMPEventBuf;
begin
  Result := 0; // Continue to next handler...
  pms := PMPEventBuf(edata);
  IPAddress := pms.client;
  if LastUserPassCount.ContainsKey(IPAddress) then
    begin
      Log(AnsiString(Format('%s: Reset USER/PASS count for %s', [ModuleName, IPAddress])));
      LastUserPassCount.Remove(IPAddress);
    end;
end;

function startup(m: PM_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
var
  Text: string;
begin
  mi := m^;
  ModuleName := name;

  if m.register_event_handler(MMI_MERCURYP, MPEVT_CONNECT, @POP3EventHandler, nil)=0 then
    Text := 'Failed to register Connect Handler' else
    begin
      Text := Format('StopPOP3Attack Connect Handler registered successfully, Min: %d', [MinConnectTime]);
      LastConnectionTime := TDictionary<TIPAddress, TDateTime>.Create;
    end;
  Log(AnsiString(Text));

  if m.register_event_handler(MMI_MERCURYP, MPEVT_COMMAND, @POP3CommandHandler, nil)=0 then
    Text := 'Failed to register Command Handler' else
    begin
      Text := 'StopPOP3Attack Command Handler registered successfully';
      LastUserPassCount := TDictionary<TIPAddress, Integer>.Create;
    end;
  Log(AnsiString(Text));

  if m.register_event_handler(MMI_MERCURYP, MPEVT_LOGIN, @POP3ResetUserPassCount, nil)=0 then
    Text := 'Failed to register ResetUserPass Handler' else
    begin
      Text := 'StopPOP3Attack ResetUserPass Handler registered successfully';
      if not Assigned(LastUserPassCount) then
        LastUserPassCount := TDictionary<TIPAddress, Integer>.Create;
    end;
  Log(AnsiString(Text));

  Result := 1; // Non-zero to indicate success!
end;

{$IF DEFINED(CLOSEDOWN)}
function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
begin
  FreeAndNil(LastUserPassCount);
  FreeAndNil(LastConnectionTime);
end;
{$ENDIF}

initialization
  LastConnectionTime := nil;
  LastUserPassCount := nil;
finalization
  LastUserPassCount.Free;
  LastConnectionTime.Free;
end.
