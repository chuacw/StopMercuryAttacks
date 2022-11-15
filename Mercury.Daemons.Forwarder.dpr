library Mercury.Daemons.Forwarder;

{.$R *.res}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$STRONGLINKTYPES OFF}
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
  Mercury.SMTP.BlackListHandler in 'Mercury.SMTP.BlackListHandler.pas',
  Winapi.Windows,
  Mercury.EnableMemoryLeak in 'Mercury.EnableMemoryLeak.pas',
  SysUtils.GuardUtils in '..\Libraries\SysUtils\SysUtils.GuardUtils.pas';

exports
  configureforwarder name 'configure';

end.
