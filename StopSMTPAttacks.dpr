library StopSMTPAttacks;

{.$R *.res}
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([vcPublic])}
{.$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

uses
  MSEvent in 'MSEvent.pas',
  MPEvent in 'MPEvent.pas',
  daemon in 'daemon.pas',
  uMercurySMTPEventHandler in 'uMercurySMTPEventHandler.pas',
  NetFwTypeLib_TLB in '..\WindowsFirewall\NetFwTypeLib_TLB.pas',
  System.Win.Firewall in '..\WindowsFirewall\System.Win.Firewall.pas';

exports startup{$IF DEFINED(CLOSEDOWN)},
        closedown
        {$ENDIF}
;

begin
end.
