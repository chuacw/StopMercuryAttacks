library Mercury.Daemons.Forwarder;

{.$R *.res}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([vcPublic])}
{$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

uses
  Winapi.Windows,
  DuplicatedIssue in 'DuplicatedIssue.pas';

exports
  UniqueTest;

end.
