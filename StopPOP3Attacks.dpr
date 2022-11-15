library StopPOP3Attacks;

{.$R *.res}
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([vcPublic])}
{.$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

uses
  daemon in 'daemon.pas',
  MPEvent in 'MPEvent.pas',
  MSEvent in 'MSEvent.pas',
  uMercuryPOP3EventHandler in 'uMercuryPOP3EventHandler.pas';

exports startup{$IF DEFINED(CLOSEDOWN)},
        closedown
        {$ENDIF}
;

begin
end.
