unit Mercury.SMTP.IPv6Mapper;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdMappedPortTCP, System.Actions, Vcl.ActnList,
  Vcl.StdActns, Vcl.Menus, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    IdMappedSMTPPortTCP: TIdMappedPortTCP;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    IdMappedPOPPortTCP: TIdMappedPortTCP;
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
    procedure InitMappedPort(AMappedPort: TIdMappedPortTCP; APort: Integer);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation
uses
  IdSocketHandle, IdGlobal;

{$R *.dfm}

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  Close;
  Application.Terminate; // this works too!
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Application.ShowMainForm := False; // Hide the main form on startup
  IdMappedPOPPortTCP.Free;
  IdMappedSMTPPortTCP.Free;

  IdMappedPOPPortTCP  := TIdMappedPortTCP.Create(Self);
  IdMappedSMTPPortTCP := TIdMappedPortTCP.Create(Self);

  InitMappedPort(IdMappedPOPPortTCP, 110);
  InitMappedPort(IdMappedSMTPPortTCP, 25);
end;

procedure TfrmMain.InitMappedPort(AMappedPort: TIdMappedPortTCP; APort: Integer);
var
  LIPv6: TIdSocketHandle;
begin
  AMappedPort.MappedPort := APort;
  AMappedPort.MappedHost := '192.168.0.2';

  LIPv6 := AMappedPort.Bindings.Add;
  LIPv6.Port := APort;
  LIPv6.IPVersion := Id_IPv6;

  AMappedPort.Active := True;
end;

end.
