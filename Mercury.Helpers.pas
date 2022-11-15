// chuacw
unit Mercury.Helpers;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface
uses
  Mercury.Daemon;

type
  TIPAddress = AnsiString;

var
  ModuleName: AnsiString = '';
  MercuryFuncPtrs: M_INTERFACE;

/// <summary>Logs the given message, LogMsg, to the System Messages window.
/// Controlled by Configuration -&gt; Mercury core module -&gt; Reporting -&gt; System message reporting level.
/// This function scrolls the system message window to keep the latest message shown.
/// <param name="LogMsg">Msg to log</param>
/// </summary>
procedure Log(const LogMsg: string); overload;
procedure Log(const LogMsg: AnsiString); overload;

procedure ShowLastConnectedTime(const LDateTime, IPAddress: AnsiString);

implementation
uses
  System.SysUtils, Winapi.Windows, Winapi.Messages;

/// <param name="LDateTime">Date/Time</param>
/// <param name="IPAddress">IP address</param>
/// <summary>Logs the last connection from a given IP address.</summary>
procedure ShowLastConnectedTime(const LDateTime, IPAddress: AnsiString); overload;
var
  Text: string;
begin
  Text := Format(AnsiString('%s last connection: %s.'), [IPAddress, LDateTime]);
  Log(Text);
end;

procedure ShowLastConnectedTime(const LDateTime, IPAddress: string); overload;
begin
  ShowLastConnectedTime(AnsiString(LDateTime), AnsiString(IPAddress));
end;

var
  LSystemMessageConsole, LPOP3MessageConsole: THandle;

function GetClassName(AHWnd: HWND): string;
var
  ALength, LLength: Integer;
begin
  LLength := 1024;
  SetLength(Result, LLength);
  ALength := Winapi.Windows.GetClassName(AHWnd, PChar(Result), LLength);
  SetLength(Result, ALength);
end;

function FindPOP3ServerWindow(hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  LClassName: string;
begin
  LClassName := GetClassName(hwnd);
  if (LClassName = 'LDUwin') and (LPOP3MessageConsole = 0) then
    begin
      LPOP3MessageConsole := hwnd;
      Result := False;
    end else Result := True;
end;

function FindSystemMessageConsole(hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  LClassName: string;
begin
  LClassName := GetClassName(hwnd);
  if (LClassName = 'LDUwin') and (LSystemMessageConsole = 0) then
    begin
      LSystemMessageConsole := hwnd;
      Result := False;
    end else Result := True;
end;

procedure ScrollMessageWindowToBottom(AHandle: THandle); overload;
var
  I: Integer;
begin
  if (AHandle <> 0) and IsWindow(AHandle) then
    for I := 1 to 5 do SendMessage(AHandle, WM_VSCROLL, SB_PAGEDOWN, 0);
end;

procedure ScrollMessageWindowToBottom; overload;
const
  SMDIChild: PChar = 'M32MDICHILD';
var
  LFrameWindow, LMDIParent, LSystemMessages, LPOP3ServerWindow: THandle;
begin
  if LSystemMessageConsole <> 0 then
    if not IsWindow(LSystemMessageConsole) then
      LSystemMessageConsole := 0;
  if LSystemMessageConsole = 0 then
    begin
      if not Assigned(MercuryFuncPtrs.get_variable) then
        Exit;
      LFrameWindow := MercuryFuncPtrs.get_variable(GV_FRAMEWINDOW);
      LMDIParent := 0; LSystemMessages := 0; LPOP3ServerWindow := 0;
      if LFrameWindow <> 0 then
        LMDIParent := FindWindowEx(LFrameWindow, 0, 'MDIClient', nil);
      if LMDIParent <> 0 then
        begin
          LSystemMessages := FindWindowEx(LMDIParent, 0, SMDIChild, 'System Messages');
          LPOP3ServerWindow := FindWindowEx(LMDIParent, 0, SMDIChild, 'Mercury POP3 Server');
        end;
      if LSystemMessages <> 0 then
        EnumChildWindows(LSystemMessages, @FindSystemMessageConsole, 0);
//      if LPOP3ServerWindow <> 0 then
//        EnumChildWindows(LPOP3ServerWindow, @FindPOP3ServerWindow, 0);
    end;
  ScrollMessageWindowToBottom(LSystemMessageConsole);
//  ScrollMessageWindowToBottom(LPOP3MessageConsole);
end;

procedure Log(const LogMsg: AnsiString);
var
  LText: AnsiString;
begin
  if MercuryFuncPtrs.dsize = 0 then Exit;  // Ensure mi is initialized!
  LText := AnsiString(Format('%s: %s', [ModuleName, LogMsg]));
  MercuryFuncPtrs.LogString(19400, LOG_NORMAL, PAnsiChar(LText));
  ScrollMessageWindowToBottom;
end;

procedure Log(const LogMsg: string);
begin
  Log(AnsiString(LogMsg));
end;

initialization
  LSystemMessageConsole := 0;
end.
