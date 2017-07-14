library StopPOP3Attacks;

{.$R *.res}
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([vcPublic])}
{.$STRONGLINKTYPES OFF}
{$WEAKLINKRTTI ON}

uses
  Mercury.Daemon in 'Mercury.Daemon.pas',
  {$IF DEFINED(DEBUG)}
  Winapi.Windows,
  {$ENDIF }
  Mercury.POP3.EventHandlers in 'Mercury.POP3.EventHandlers.pas',
  Mercury.Helpers in 'Mercury.Helpers.pas',
  Mercury.EventLog in 'Mercury.EventLog.pas',
  Mercury.POP3.Events in 'Mercury.POP3.Events.pas';

exports startup{$IF DEFINED(CLOSEDOWN)},
        closedown
        {$ENDIF}
;

{$IF DEFINED(DEBUG)}
procedure DllMain(reason: Integer);
begin
  if reason = DLL_PROCESS_DETACH then
    OutputDebugString('DLL PROCESS DETACH')
  else if reason = DLL_PROCESS_ATTACH then
    OutputDebugString('DLL PROCESS ATTACH')
  else if reason = DLL_THREAD_ATTACH then
    OutputDebugString('DLL THREAD ATTACH')
  else if reason = DLL_THREAD_DETACH then
    OutputDebugString('DLL THREAD DETACH')
  else
    OutputDebugString('DllMain');
end;

begin
  DllProc := DllMain;
{$ENDIF}
end.
