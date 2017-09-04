unit Mercury.SMTP.IPv6Mapper;

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
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  Close;
  Application.Terminate; // this works too!
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Application.ShowMainForm := False; // Hide the main form on startup
end;

end.
