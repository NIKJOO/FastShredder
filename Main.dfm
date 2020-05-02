object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Eliminator '
  ClientHeight = 391
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
    Top = 372
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
  end
  object GB_FreeSWipe: TGroupBox
    Left = 8
    Top = 285
    Width = 503
    Height = 56
    Enabled = False
    TabOrder = 5
    object lblDriveLetter: TLabel
      Left = 25
      Top = 19
      Width = 32
      Height = 13
      Caption = 'Drive :'
      Enabled = False
    end
    object cbLogicalDrivers: TComboBoxEx
      Left = 63
      Top = 16
      Width = 145
      Height = 22
      ItemsEx = <>
      Style = csExDropDownList
      Enabled = False
      TabOrder = 0
    end
    object btnFreeSWipe: TButton
      Left = 356
      Top = 14
      Width = 110
      Height = 25
      Caption = 'Wipe'
      Enabled = False
      TabOrder = 1
      OnClick = btnFreeSWipeClick
    end
  end
  object GB_Browse: TGroupBox
    Left = 8
    Top = 8
    Width = 308
    Height = 49
    TabOrder = 0
    object btnSelectFiles: TButton
      Left = 44
      Top = 10
      Width = 110
      Height = 25
      Caption = 'Add Files'
      TabOrder = 0
      OnClick = btnSelectFilesClick
    end
    object btnAddfromDir: TButton
      Left = 160
      Top = 10
      Width = 110
      Height = 25
      Caption = 'Open Directory'
      TabOrder = 1
      OnClick = btnAddfromDirClick
    end
  end
  object lstWipe: TListView
    Left = 8
    Top = 63
    Width = 503
    Height = 158
    Columns = <
      item
        AutoSize = True
        Caption = 'Selected Files ...'
        MaxWidth = 5000
        MinWidth = 499
      end>
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    SortType = stText
    TabOrder = 2
    ViewStyle = vsReport
  end
  object GB_Wipe: TGroupBox
    Left = 322
    Top = 8
    Width = 189
    Height = 49
    TabOrder = 1
    object btnDestroyFiles: TButton
      Left = 42
      Top = 10
      Width = 110
      Height = 25
      Caption = 'Wipe'
      TabOrder = 0
      OnClick = btnDestroyFilesClick
    end
  end
  object GB_Methods: TGroupBox
    Left = 8
    Top = 227
    Width = 504
    Height = 49
    TabOrder = 3
    object lblWipeStd: TLabel
      Left = 16
      Top = 16
      Width = 70
      Height = 13
      Caption = 'Wipe Method :'
    end
    object cbWipeMethods: TComboBox
      Left = 97
      Top = 12
      Width = 249
      Height = 22
      Style = csOwnerDrawFixed
      ItemIndex = 0
      TabOrder = 0
      Text = 'Secure - 1 Pass [ Fast - Low Security ]'
      Items.Strings = (
        'Secure - 1 Pass [ Fast - Low Security ]'
        'DoD - 3 Passes [ Fast - Medium Security ]'
        'NSA - 7 Passes [ Medium - Good Security ]'
        'Gutmann - 35 Passes [ Slow - Ultra Security ]')
    end
  end
  object chFreeSpaceWipe: TCheckBox
    Left = 15
    Top = 278
    Width = 201
    Height = 17
    Caption = 'Free Space Wipe [ Also Erase MFT ]'
    TabOrder = 4
    OnClick = chFreeSpaceWipeClick
  end
  object Progress: TProgressBar
    Left = 8
    Top = 347
    Width = 504
    Height = 19
    Max = 0
    Smooth = True
    MarqueeInterval = 1
    Step = 1
    TabOrder = 6
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
    Left = 35
    Top = 90
  end
end
