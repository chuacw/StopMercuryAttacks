program MercuryIPv6Mapper;

uses
  Vcl.Forms,
  Mercury.SMTP.IPv6Mapper in 'Mercury.SMTP.IPv6Mapper.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
