object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Eliminator '
  ClientHeight = 319
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Status: TStatusBar
    Left = 0
    Top = 300
    Width = 520
    Height = 19
    Panels = <
      item
        Text = 'Status :'
        Width = 50
      end
      item
        Width = 50
      end>
    ExplicitTop = 282
    ExplicitWidth = 517
  end
  object GB_FreeSWipe: TGroupBox
    Left = 8
    Top = 227
    Width = 503
    Height = 64
    Caption = 'Free Space Wipe'
    TabOrder = 1
    object lblDriveLetter: TLabel
      Left = 15
      Top = 30
      Width = 32
      Height = 13
      Caption = 'Drive :'
    end
    object cbLogicalDrivers: TComboBoxEx
      Left = 53
      Top = 27
      Width = 145
      Height = 22
      ItemsEx = <>
      Style = csExDropDownList
      TabOrder = 0
    end
    object btnFreeSWipe: TButton
      Left = 406
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Wipe'
      TabOrder = 1
      OnClick = btnFreeSWipeClick
    end
  end
  object GB_Browse: TGroupBox
    Left = 8
    Top = 172
    Width = 117
    Height = 49
    TabOrder = 2
    object btnSelectFiles: TButton
      Left = 15
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 0
      OnClick = btnSelectFilesClick
    end
  end
  object lstWipe: TListView
    Left = 8
    Top = 8
    Width = 503
    Height = 158
    Columns = <
      item
        AutoSize = True
        Caption = 'Selected Files ...'
      end>
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    SortType = stText
    TabOrder = 3
    ViewStyle = vsReport
  end
  object GB_Wipe: TGroupBox
    Left = 392
    Top = 172
    Width = 119
    Height = 49
    TabOrder = 4
    object btnDestroyFiles: TButton
      Left = 22
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Wipe'
      TabOrder = 0
      OnClick = btnDestroyFilesClick
    end
  end
  object GB_Methods: TGroupBox
    Left = 131
    Top = 172
    Width = 255
    Height = 49
    TabOrder = 5
    object lblWipeStd: TLabel
      Left = 16
      Top = 16
      Width = 70
      Height = 13
      Caption = 'Wipe Method :'
    end
    object cbWipeMethods: TComboBox
      Left = 92
      Top = 12
      Width = 145
      Height = 22
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 0
      Text = 'Secure - 1 Pass'
      Items.Strings = (
        'Secure - 1 Pass'
        'DoD - 3 Passes'
        'NSA - 7 Passes'
        'Gutmann - 35 Passes')
    end
  end
  object OpenFile: TOpenDialog
    Filter = 'Any File|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 898
    Top = 666
  end
  object FShredder: TIdThreadComponent
    Active = False
    Loop = False
    Priority = tpHighest
    StopMode = smTerminate
    ThreadName = 'Thread'
    OnRun = FShredderRun
    OnTerminate = FShredderTerminate
    Left = 945
    Top = 665
  end
  object FreeSpaceWipe: TIdThreadComponent
    Active = False
    Loop = False
    Priority = tpHighest
    StopMode = smTerminate
    OnRun = FreeSpaceWipeRun
    OnTerminate = FreeSpaceWipeTerminate
    Left = 20
    Top = 15
  end
end
