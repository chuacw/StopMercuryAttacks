unit Mercury.SMTP.ConfigureBlacklist;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList;

type
  TfrmBlacklist = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    ListBox1: TListBox;
    Panel2: TPanel;
    btnRemove: TButton;
    btnAdd: TButton;
    edBlacklist: TEdit;
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FDirty: Boolean;
    function GetBlacklist: TStrings;
    procedure SetBlacklist(const Value: TStrings);
    procedure OnIdle(Sender: TObject; var Done: Boolean);
    procedure ScrollToBottom;
  public
    { Public declarations }
    property Blacklist: TStrings read GetBlacklist write SetBlacklist;
  end;

var
  frmBlacklist: TfrmBlacklist;

implementation

{$R *.dfm}

procedure TfrmBlacklist.OnIdle(Sender: TObject; var Done: Boolean);
begin
  btnRemove.Enabled := (ListBox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1);
  btnAdd.Enabled := edBlacklist.Text <> '';
  btnOk.Enabled := FDirty;
end;

procedure TfrmBlacklist.ScrollToBottom;
begin
  ListBox1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TfrmBlacklist.SetBlacklist(const Value: TStrings);
begin
  ListBox1.Items.AddStrings(Value);
  ScrollToBottom;
end;

procedure TfrmBlacklist.btnAddClick(Sender: TObject);
var
  LBlacklistedDomain: string;
begin
  LBlacklistedDomain := edBlacklist.Text;
  if ListBox1.Items.IndexOf(LBlacklistedDomain)=-1 then
    begin
      ListBox1.Items.Add(LBlacklistedDomain);
      FDirty := True;
    end;
  edBlacklist.Text := '';
  ScrollToBottom;
end;

procedure TfrmBlacklist.btnCancelClick(Sender: TObject);
begin
//  ModalResult := mrCancel;
end;

procedure TfrmBlacklist.btnOkClick(Sender: TObject);
begin
//  ModalResult := mrOk;
end;

procedure TfrmBlacklist.btnRemoveClick(Sender: TObject);
var
  I: Integer;
  LSelCount: Integer;
begin
  if (ListBox1.ItemIndex <> -1) and not (ListBox1.MultiSelect) then
    begin
      ListBox1.Items.Delete(ListBox1.ItemIndex);
      FDirty := True;
    end;
  if ListBox1.MultiSelect then
    begin
      LSelCount := ListBox1.SelCount;
      for I := ListBox1.Count-1 downto 0 do
        if ListBox1.Selected[I] then
          begin
            ListBox1.Items.Delete(I);
            Dec(LSelCount);
            FDirty := True;
            if LSelCount = 0 then
              Break;
          end;
    end;
end;

procedure TfrmBlacklist.FormCreate(Sender: TObject);
begin
  Application.OnIdle := OnIdle;
  FDirty := False;
end;

function TfrmBlacklist.GetBlacklist: TStrings;
begin
  Result := ListBox1.Items;
end;

end.
