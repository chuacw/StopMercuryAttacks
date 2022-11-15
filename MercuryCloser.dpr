program MercuryCloser;
{$APPTYPE GUI}
{$R *.res}

uses
  Winapi.Windows,
  Winapi.Messages,
  CFL.WinUtils in '..\GetWindowTexts\CFL.WinUtils.pas';

var
  LWindow: HWND; LMsg: UINT;
  WParam: Winapi.Windows.WPARAM;
  LParam: Winapi.Windows.LPARAM;
begin
  LWindow := FindWindow('Mercury/32');
  if LWindow <> 0 then
    begin
      LMsg := WM_QUIT;
      WParam := 0;
      LParam := 0;
      PostMessage(LWindow, LMsg, WParam, LParam);
    end;
end.
