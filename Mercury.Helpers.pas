// chuacw
unit Mercury.Helpers;

interface
uses Mercury.Daemon;

type
  TIPAddress = AnsiString;

var
  ModuleName: AnsiString = '';
  mi: M_INTERFACE;

///<summary>Logs the given message, LogMsg, to the System Messages window.
/// Controlled by Configuration -&gt; Mercury core module -&gt; Reporting -&gt; System message reporting level.
///<param name="LogMsg">Msg to log</param>
///</summary>
procedure Log(const LogMsg: string);

procedure ShowLastConnectedTime(const LDateTime, IPAddress: AnsiString);

implementation
uses System.SysUtils;

///<param name="LDateTime">Date/Time</param>
///<param name="IPAddress">IP address</param>
///<summary>Logs the last connection from a given IP address.</summary>
procedure ShowLastConnectedTime(const LDateTime, IPAddress: AnsiString);
var
  Text: string;
begin
  Text := Format('%s last connection: %s.', [IPAddress, LDateTime]);
  Log(Text);
end;

procedure Log(const LogMsg: string);
var
  LText: AnsiString;
begin
  if mi.dsize = 0 then Exit;  // Ensure mi is initialized!
  LText := AnsiString(Format('%s: %s', [ModuleName, LogMsg]));
  mi.LogString(19400, LOG_NORMAL, PAnsiChar(LText));
end;

end.
