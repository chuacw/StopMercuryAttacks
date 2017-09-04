
library Mercury.Daemons.MapIPv6;

{$WEAKLINKRTTI ON}

uses
  System.SysUtils,
  System.Classes,
  IdMappedPortTCP,
  IdSocketHandle,
  IdStack,
  IdGlobal,
  Mercury.Daemon in 'Mercury.Daemon.pas',
  Mercury.Helpers in 'Mercury.Helpers.pas';

{$R *.res}

var
  IdMappedSMTPPortTCP: TIdMappedPortTCP;
  IdMappedPOPPortTCP: TIdMappedPortTCP;

procedure InitMappedPort(out AMappedPort: TIdMappedPortTCP; APort: Integer);
var
  LIPv6: TIdSocketHandle;
begin
  AMappedPort := TIdMappedPortTCP.Create(nil);
  AMappedPort.MappedPort := APort;
  AMappedPort.MappedHost := '192.168.0.2';

  LIPv6 := AMappedPort.Bindings.Add;
  LIPv6.Port := APort;
  LIPv6.IPVersion := Id_IPv6;

  AMappedPort.Active := True;
end;

procedure FreeMappedPorts;
begin
  IdMappedPOPPortTCP.Free;
  IdMappedSMTPPortTCP.Free;
end;

function startup(m: PM_INTERFACE; var Flags: UINT_32; Name,
  Param: PAnsiChar): Smallint; cdecl; export;
begin
  mi := m^;
  ModuleName := 'IPv6 Mapper';
  TIdStack.IncUsage;
  try
    try

      if not GStack.SupportsIPv6 then
        begin
          Log('IPv6 not supported!');
          Exit(0); // Not supported!
        end;

      InitMappedPort(IdMappedPOPPortTCP, 110);
      InitMappedPort(IdMappedSMTPPortTCP, 25);

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

function closedown(m: PM_INTERFACE; code: UINT_32; name: PAnsiChar;
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
