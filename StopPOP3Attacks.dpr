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
  case reason of
    DLL_PROCESS_DETACH: OutputDebugString('DLL PROCESS DETACH');
    DLL_PROCESS_ATTACH: OutputDebugString('DLL PROCESS ATTACH');
    DLL_THREAD_ATTACH: OutputDebugString('DLL THREAD ATTACH');
    DLL_THREAD_DETACH: OutputDebugString('DLL THREAD DETACH');
  else
    OutputDebugString('DllMain');
  end;
end;

begin
  DllProc := DllMain;
{$ENDIF}
end.
