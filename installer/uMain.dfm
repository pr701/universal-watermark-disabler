object frmMain: TfrmMain
  Left = 347
  Top = 248
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Universal Watermark Disabler'
  ClientHeight = 222
  ClientWidth = 433
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 177
    Width = 433
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'pnlBottom'
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    object shpPanel: TShape
      Left = 0
      Top = 0
      Width = 433
      Height = 45
      Align = alTop
      Brush.Color = clWindow
      Pen.Color = clAppWorkSpace
      Pen.Style = psClear
    end
    object lblPtr: TLabel
      Left = 9
      Top = 16
      Width = 68
      Height = 13
      Caption = 'PainteR, 2015'
      Color = clWindow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object btnInstall: TButton
      Left = 344
      Top = 10
      Width = 83
      Height = 25
      Caption = 'btnInstall'
      Enabled = False
      TabOrder = 0
      OnClick = btnInstallClick
    end
  end
  object grpInf: TGroupBox
    Left = 8
    Top = 8
    Width = 417
    Height = 97
    Caption = 'grpInfo'
    TabOrder = 1
    object lblEdition: TLabel
      Left = 98
      Top = 24
      Width = 311
      Height = 13
      AutoSize = False
      Caption = 'lblEdition'
    end
    object lblVerApi: TLabel
      Left = 98
      Top = 40
      Width = 311
      Height = 13
      AutoSize = False
      Caption = 'lblVerApi'
    end
    object lblVerReg: TLabel
      Left = 98
      Top = 56
      Width = 311
      Height = 13
      AutoSize = False
      Caption = 'lblVerReg'
    end
    object lblVerReg_m: TLabel
      Left = 8
      Top = 56
      Width = 86
      Height = 13
      AutoSize = False
      Caption = 'lblVerReg'
    end
    object lblVerApi_m: TLabel
      Left = 8
      Top = 40
      Width = 81
      Height = 13
      AutoSize = False
      Caption = 'lblVerApi'
    end
    object lblEdition_m: TLabel
      Left = 8
      Top = 24
      Width = 81
      Height = 13
      AutoSize = False
      Caption = 'lblEdition'
    end
    object lblStatus_m: TLabel
      Left = 8
      Top = 72
      Width = 81
      Height = 13
      AutoSize = False
      Caption = 'lblStatus'
    end
    object lblStatus: TLabel
      Left = 98
      Top = 72
      Width = 311
      Height = 13
      AutoSize = False
      Caption = 'lblVStatus'
    end
  end
  object grpAbt: TGroupBox
    Left = 8
    Top = 112
    Width = 417
    Height = 57
    Caption = 'grpAbt'
    TabOrder = 2
    object lblThx: TLabel
      Left = 8
      Top = 20
      Width = 401
      Height = 13
      AutoSize = False
      Caption = 'lblThx'
    end
    object lblTihiyWeb: TLabel
      Left = 8
      Top = 36
      Width = 201
      Height = 13
      AutoSize = False
      Caption = 'lblTihiyWeb'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = lblTihiyWebClick
      OnMouseMove = lblTihiyWebMouseMove
      OnMouseLeave = lblTihiyWebMouseLeave
    end
  end
end
