unit uMercuryPOP3EventHandler;

interface
uses MPEvent, MSEvent, daemon;

function startup(m: PM_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;

{$IF DEFINED(CLOSEDOWN)}
function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;
{$ENDIF}

implementation
uses System.SysUtils, System.Generics.Collections, System.DateUtils;

var
  ModuleName: AnsiString;
  mi: M_INTERFACE;
  LastConnectionTime: TDictionary<AnsiString, TDateTime>;

procedure Log(const Text: AnsiString);
begin
  mi.logstring(19400, LOG_NORMAL, PAnsiChar(Text));
end;

function POP3EventHandler(module: UINT_32; event: UINT_32;
  edata: Pointer; cdata: Pointer): INT_32; cdecl;

var
  IPAddress: AnsiString;

  procedure ShowLastConnectedTime(const LDateTime: AnsiString);
  var
    Text: AnsiString;
  begin
    Text := AnsiString(Format('%s: %s last connection: %s.', [ModuleName, IPAddress, LDateTime]));
    Log(Text);
  end;

var
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
        ShowLastConnectedTime(AnsiString(FormatDateTime('d mmm h:nn:ss am/pm', LastConnectedOn)));
        if WithinPastSeconds(Now, LastConnectedOn, 5) then
          begin
            Log(AnsiString(Format('%s: Connection %s blacklisted.', [ModuleName, IPAddress])));
            Result := -3; // Blacklist!!!
          end;

      end else
      begin
        // LDateTime := 'never';
        ShowLastConnectedTime('never');
      end;
    LastConnectionTime.AddOrSetValue(IPAddress, Now);
  except
    on E: Exception do
      begin
        Log(AnsiString(E.Message));
      end;
  end;
end;

function startup(m: PM_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
var
  Text: string;
begin
  ModuleName := name;
  if m.register_event_handler(MMI_MERCURYP, MSEVT_CONNECT, @POP3EventHandler, nil)=0 then
    Text := 'Failed to register event handler' else
    begin
      Text := 'StopPOP3Attack registered successfully';
      LastConnectionTime := TDictionary<AnsiString, TDateTime>.Create;
    end;
  m.logstring(19400, LOG_SIGNIFICANT, PAnsiChar(AnsiString(Text)));
  mi := m^;
  Result := 1; // Non-zero to indicate success!
end;

{$IF DEFINED(CLOSEDOWN)}
function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint;
begin
  FreeAndNil(LastConnectionTime);
end;
{$ENDIF}

initialization
  LastConnectionTime := nil;
finalization
  LastConnectionTime.Free;
end.