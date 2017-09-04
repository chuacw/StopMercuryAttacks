object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Mercury SMTP IPv6 Mapper'
  ClientHeight = 292
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IdMappedSMTPPortTCP: TIdMappedPortTCP
    Bindings = <
      item
        IP = '::'
        IPVersion = Id_IPv6
        Port = 25
      end>
    DefaultPort = 25
    MappedHost = '192.168.0.2'
    MappedPort = 25
    Left = 184
    Top = 96
  end
  object TrayIcon1: TTrayIcon
    PopupMenu = PopupMenu1
    Visible = True
    Left = 272
    Top = 96
  end
  object PopupMenu1: TPopupMenu
    Left = 344
    Top = 96
    object Exit1: TMenuItem
      Caption = 'E&xit'
      Hint = 'Exit|Quits the application'
      ImageIndex = 43
      OnClick = Exit1Click
    end
  end
  object IdMappedPOPPortTCP: TIdMappedPortTCP
    Active = True
    Bindings = <
      item
        IP = '::'
        IPVersion = Id_IPv6
        Port = 110
      end>
    DefaultPort = 110
    MappedHost = '192.168.0.2'
    MappedPort = 110
    Left = 176
    Top = 160
  end
end
