program TestStopSMTPAttacks;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Mercury.SMTP.Events in 'Mercury.SMTP.Events.pas',
  Mercury.SMTP.EventHandlers in 'Mercury.SMTP.EventHandlers.pas',
  Mercury.SMTP.ConfigureBlacklist in 'Mercury.SMTP.ConfigureBlacklist.pas' {frmBlacklist},
  Mercury.POP3.Events in 'Mercury.POP3.Events.pas',
  Mercury.Helpers in 'Mercury.Helpers.pas',
  Mercury.EventLog in 'Mercury.EventLog.pas',
  Mercury.EnableMemoryLeak in 'Mercury.EnableMemoryLeak.pas',
  Mercury.Daemon in 'Mercury.Daemon.pas',
  System.Win.Firewall in '..\WindowsFirewall\System.Win.Firewall.pas',
  NetFwTypeLib_TLB in '..\WindowsFirewall\NetFwTypeLib_TLB.pas',
  Mercury.SMTP.Consts in 'Mercury.SMTP.Consts.pas',
  SysUtils.GuardUtils in '..\Libraries\SysUtils\SysUtils.GuardUtils.pas';

function RegisterEventHandler(module: UINT_32; event: UINT_32; eproc: EVENTPROC; cdata: Pointer): INT_32; cdecl;
begin
  Result := 1;
end;

procedure LogString(ltype, priority: INT_16; str: PAnsiChar); cdecl;
begin
  WriteLn(str);
end;


// This simulates the Mercury SMTP server by calling the startup function
procedure Test;
var
  AEventBuf: TMSEventBuf;
  LEmailFrom, LIPAddr: AnsiString;
  LMercuryFuncPtrs: TMercuryFuncPtrs;
  LFlags: UINT32;
  LName, LParam: AnsiString;
  LPName, LPParam: PAnsiChar;
begin
  FillChar(LMercuryFuncPtrs, SizeOf(LMercuryFuncPtrs), 0);
  LMercuryFuncPtrs.dsize := SizeOf(LMercuryFuncPtrs);
  LMercuryFuncPtrs.RegisterEventHandler := RegisterEventHandler;
  LMercuryFuncPtrs.LogString := LogString;
  LName := 'TestStopSMTPAttacks';
  LParam := '';
  LPName := PAnsiChar(LName);
  LPParam := PAnsiChar(LParam);

  startup(@LMercuryFuncPtrs, LFlags, LPName, LPParam);

  FillChar(AEventBuf, SizeOf(AEventBuf), 0);
  LIPAddr := '141.98.10.136';
  LEmailFrom := AnsiString(Format('%s: %s', [SMailFrom, 'chuacw@gmail.com']));
  AEventBuf.client := PAnsiChar(LIPAddr);
  AEventBuf.inbuf := PAnsiChar(LEmailFrom);
  SMTPMailFromHandler(0, 0, @AEventBuf, nil);

  closedown(@LMercuryFuncPtrs, LFlags, LPName, LPParam);

end;

begin
  Test;
end.
