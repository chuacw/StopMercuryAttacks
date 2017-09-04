library Mercury.Daemons.StopSMTPAttacks;

{.$R *.res}
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([vcPublic])}
{.$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

uses
  Mercury.SMTP.Events in 'Mercury.SMTP.Events.pas',
  Mercury.POP3.Events in 'Mercury.POP3.Events.pas',
  Mercury.Daemon in 'Mercury.Daemon.pas',
  Mercury.SMTP.EventHandlers in 'Mercury.SMTP.EventHandlers.pas',
  NetFwTypeLib_TLB in '..\WindowsFirewall\NetFwTypeLib_TLB.pas',
  System.Win.Firewall in '..\WindowsFirewall\System.Win.Firewall.pas',
  Mercury.Helpers in 'Mercury.Helpers.pas',
  Mercury.EventLog in 'Mercury.EventLog.pas',
  SysUtils.GuardUtils in '..\Libraries\SysUtils.GuardUtils.pas',
  Mercury.SMTP.BlackListHandler in 'Mercury.SMTP.BlackListHandler.pas';

exports startup{$IF DEFINED(CLOSEDOWN)},
        closedown
        {$ENDIF}
;

begin
end.
