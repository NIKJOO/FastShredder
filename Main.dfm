object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FAST Data Shredder'
  ClientHeight = 143
  ClientWidth = 303
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Status: TLabel
    Left = 52
    Top = 116
    Width = 15
    Height = 13
  end
  object lblStatus: TLabel
    Left = 8
    Top = 116
    Width = 38
    Height = 13
    Caption = 'Status :'
  end
  object btnSelectFiles: TButton
    Left = 8
    Top = 8
    Width = 278
    Height = 48
    Caption = 'Select Files ...'
    TabOrder = 0
    OnClick = btnSelectFilesClick
  end
  object btnDestroyFiles: TButton
    Left = 8
    Top = 62
    Width = 278
    Height = 48
    Caption = 'Destroy'
    TabOrder = 1
    OnClick = btnDestroyFilesClick
  end
  object OpenFile: TOpenDialog
    Filter = 'Any File|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 268
    Top = 251
  end
  object Shredder_Thread: TIdThreadComponent
    Active = False
    Loop = False
    Priority = tpHighest
    StopMode = smTerminate
    ThreadName = 'Thread'
    OnRun = Shredder_ThreadRun
    OnTerminate = Shredder_ThreadTerminate
    Left = 250
    Top = 230
  end
end
