library Mercury.Daemons.MapIPv6;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Classes,
  System.StrUtils,
  System.Types,
  IdMappedPortTCP,
  IdSocketHandle,
  IdStack,
  IdContext,
  IdGlobal,
  Mercury.Daemon in 'Mercury.Daemon.pas',
  Mercury.Helpers in 'Mercury.Helpers.pas',
  SysUtils.EventUtils in '..\Libraries\SysUtils\SysUtils.EventUtils.pas';

{$R *.res}

var
  GMappedPorts: TList<TIdMappedPortTCP>;
  GIdMappedSMTPPortTCP: TIdMappedPortTCP;
  GIdMappedPOPPortTCP: TIdMappedPortTCP;

procedure InitMappedPort(var AMappedPort: TIdMappedPortTCP; 
  const ADestinationHostIP: string; ADestinationPort: Integer);
var
  LIPv6: TIdSocketHandle;
begin
  AMappedPort := TIdMappedPortTCP.Create(nil);
  AMappedPort.MappedPort := ADestinationPort;
  AMappedPort.MappedHost := ADestinationHostIP;

//  AMappedPort.OnConnect := TEventMaker<TIdContext>.MakeEvent(procedure (AContext: TIdContext)
//  var
//    LPeerIP: string;
//  begin
//    LPeerIP := AContext.Connection.Socket.Binding.PeerIP; // IPv6 of connection origin
//  end);

  LIPv6 := AMappedPort.Bindings.Add;
  LIPv6.Port := ADestinationPort;
  LIPv6.IPVersion := Id_IPv6;

  AMappedPort.Active := True;
end;

procedure FreeMappedPorts;
begin
  GMappedPorts.Free;
//  GIdMappedPOPPortTCP.Free;
//  GIdMappedSMTPPortTCP.Free;
end;

function startup(m: PMercuryFuncPtrs; var Flags: UINT_32; Name,
  Param: PAnsiChar): Smallint; cdecl; export;
var
  LError: Boolean;
  LParam, SPort: string;
  SIPs, SPorts: TStringDynArray;
  LPort: Integer;
  LMappedPort: TIdMappedPortTCP;
begin
  MercuryFuncPtrs := m^;
  ModuleName := 'IPv6 Mapper';
  TIdStack.IncUsage;

  try

    if not GStack.SupportsIPv6 then
      begin
        Log('IPv6 not supported!');
        Exit(0); // Not supported!
      end;

    GMappedPorts := nil;
    GIdMappedPOPPortTCP := nil;
    GIdMappedSMTPPortTCP := nil;
    LError := False;

    try

      LParam := string(AnsiString(Param));
      GMappedPorts := TObjectList<TIdMappedPortTCP>.Create(True); // frees objects
      if LParam <> '' then
        begin
          SIPs   := SplitString(LParam, ':');
          if Length(SIPs)>1 then
            SPorts := SplitString(SIPs[1], ',');
          for SPort in SPorts do
            begin
              LPort := StrToInt(SPort);
              try
                InitMappedPort(LMappedPort, SIPs[0], LPort);
                GMappedPorts.Add(LMappedPort);
              except
                LError := True;
              end;
            end;
        end else
        begin
          InitMappedPort(GIdMappedSMTPPortTCP, '127.0.0.1', 25);
          InitMappedPort(GIdMappedPOPPortTCP, '127.0.0.1', 110);

          GMappedPorts.Add(GIdMappedSMTPPortTCP);
          GMappedPorts.Add(GIdMappedPOPPortTCP);
        end;

      for LMappedPort in GMappedPorts do
        begin
          // procedure(AContext: TIdContext; AException: Exception) of object;
//          var LOnException: TIdServerThreadExceptionEvent := nil;
          LMappedPort.OnException := nil; // Handle exceptions
        end;

      if not LError then
        Log('Mapped IPv6 successfully.');
      Result := 1; // Return a non-zero for success!
    except
      FreeMappedPorts;
      Log('Failed to map IPv6!');
      Result := 0;
    end;
  finally
    TIdStack.DecUsage;
  end;
end;

function closedown(m: PMercuryFuncPtrs; code: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;
begin
  try
    FreeMappedPorts;
    Log('Mapped ports freed.');
  except
    Log('Unable to free mapped ports');
  end;
  Result := 0; // Caller does nothing with the result
end;

exports
  startup, closedown;

begin
end.
