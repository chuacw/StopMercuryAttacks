object frmBlacklist: TfrmBlacklist
  Left = 0
  Top = 0
  ActiveControl = edBlacklist
  Caption = 'Configure Blacklist'
  ClientHeight = 572
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 480
    Width = 425
    Height = 92
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      425
      92)
    object btnOk: TButton
      Left = 288
      Top = 56
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      Enabled = False
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 136
      Top = 56
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object btnAdd: TButton
      Left = 344
      Top = 19
      Width = 75
      Height = 25
      Anchors = [akBottom]
      Caption = 'Add'
      Enabled = False
      TabOrder = 2
      OnClick = btnAddClick
    end
    object edBlacklist: TEdit
      Left = 12
      Top = 19
      Width = 309
      Height = 21
      TabOrder = 3
    end
  end
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 318
    Height = 480
    Align = alClient
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 318
    Top = 0
    Width = 107
    Height = 480
    Align = alRight
    TabOrder = 2
    object btnRemove: TButton
      Left = 16
      Top = 256
      Width = 75
      Height = 25
      Caption = 'Remove'
      Enabled = False
      TabOrder = 0
      OnClick = btnRemoveClick
    end
  end
end
