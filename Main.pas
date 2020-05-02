{*------------------------------------------------------------------------------
  Data Shredder / Free Space Wiper

  Description :
  This application uses direct pointer to files for owerwriting content via
  threading that speedup process and don't let app going to be freez.


  Copyright 2020 MIT License.

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
  THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  Developer : Nima Nikjoo
  Email     : nima.nikjoo@gmail.com

-------------------------------------------------------------------------------}

unit Main;

{$R+}{$Q+}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl,IdBaseComponent, IdThreadComponent,
  Vcl.ComCtrls, System.UITypes, System.Types, System.IOUtils,  ActiveX,ComObj, System.StrUtils,Masks;

type
  TfrmMain = class(TForm)
    OpenFile: TOpenDialog;
    FShredder: TIdThreadComponent;
    Status: TStatusBar;
    FreeSpaceWipe: TIdThreadComponent;
    GB_FreeSWipe: TGroupBox;
    lblDriveLetter: TLabel;
    cbLogicalDrivers: TComboBoxEx;
    btnFreeSWipe: TButton;
    GB_Browse: TGroupBox;
    btnSelectFiles: TButton;
    lstWipe: TListView;
    GB_Wipe: TGroupBox;
    btnDestroyFiles: TButton;
    GB_Methods: TGroupBox;
    lblWipeStd: TLabel;
    cbWipeMethods: TComboBox;
    btnAddfromDir: TButton;
    chFreeSpaceWipe: TCheckBox;
    Progress: TProgressBar;
    procedure btnSelectFilesClick(Sender: TObject);
    procedure btnDestroyFilesClick(Sender: TObject);
    procedure FShredderRun(Sender: TIdThreadComponent);
    procedure FShredderTerminate(Sender: TIdThreadComponent);
    procedure ShredFileAndDelete;
    function  RandomPassword(PLen: Integer): string;
    procedure FormCreate(Sender: TObject);
    procedure btnFreeSWipeClick(Sender: TObject);
    procedure FreeSpaceWipeRun(Sender: TIdThreadComponent);
    procedure FreeSpaceWipeTerminate(Sender: TIdThreadComponent);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnAddfromDirClick(Sender: TObject);
    function  MyGetFiles(const Path, Masks: string): TStringDynArray;
    procedure chFreeSpaceWipeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;




var
  frmMain: TfrmMain;
  JobStatus:Boolean;
  Free_SWipe:Boolean;
  FilesInDir:TStringList;

implementation

{$R *.dfm}


procedure SetFileCreationTime(const FileName: string; const DateTime: TDateTime);
const
  FILE_WRITE_ATTRIBUTES = $0100;
var
  Handle: THandle;
  SystemTime: TSystemTime;
  FileTime: TFileTime;
begin
  Handle := CreateFile(PChar(FileName), FILE_WRITE_ATTRIBUTES,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, 0);
  if Handle=INVALID_HANDLE_VALUE then
    RaiseLastOSError;
  try
    DateTimeToSystemTime(DateTime, SystemTime);
    if not SystemTimeToFileTime(SystemTime, FileTime) then
      RaiseLastOSError;
    if not SetFileTime(Handle, @FileTime, nil, nil) then
      RaiseLastOSError;
  finally
    CloseHandle(Handle);
  end;
end;


procedure TfrmMain.btnFreeSWipeClick(Sender: TObject);
begin
 Free_SWipe := False;
 if Trim(cbLogicalDrivers.Text) = '' then
 begin
  MessageBoxA(self.Handle,'Please Select Drive You Want To Wipe !','Error',MB_ICONERROR);
 end else
     begin
        btnFreeSWipe.Enabled := False;
        FreeSpaceWipe.Start;
     end;
end;

procedure TfrmMain.btnSelectFilesClick(Sender: TObject);
var
 I:Integer;
begin
 lstWipe.Clear;
 if OpenFile.Execute(self.Handle) then
 begin
  for I := 0 to OpenFile.Files.Count - 1 do
  begin
    lstWipe.AddItem(OpenFile.Files[I],nil);
  end;
 end;
end;


procedure TfrmMain.chFreeSpaceWipeClick(Sender: TObject);
begin
 if GB_FreeSWipe.Enabled = False then
 begin
   GB_FreeSWipe.Enabled := True;
   lblDriveLetter.Enabled := True;
   cbLogicalDrivers.Enabled := True;
   btnFreeSWipe.Enabled := True;
 end else
      begin
       GB_FreeSWipe.Enabled := False;
       lblDriveLetter.Enabled := False;
       cbLogicalDrivers.Enabled := False;
       btnFreeSWipe.Enabled := False;
      end;
end;

function TfrmMain.RandomPassword(PLen: Integer): string;
var
  str: string;
begin
  Randomize;
  str    := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()<>?"{}[]|\/';
  Result := '';
  repeat
    Result := Result + str[Random(Length(str)) + 1];
  until (Length(Result) = PLen)
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 FShredder.Stop;
 FreeSpaceWipe.Stop;
 Application.Terminate;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  Drivelist:TStringDynArray;
  Drive:String;
begin
  Drivelist := TDirectory.GetLogicalDrives;
  for Drive in Drivelist do
  begin
     cbLogicalDrivers.Items.Add(Drive);
  end;
end;


procedure TfrmMain.FreeSpaceWipeRun(Sender: TIdThreadComponent);
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  CBlock,I:Integer;
  F:file;
  Data,FileName:string;
  hFile:THandle;
  FreeSize:UInt64;
  FilesInDir:TStringDynArray;
begin
  try
     if (cbLogicalDrivers.Text <> '') then
     begin

        FShredder.Stop;
        lstWipe.Clear;
        btnDestroyFiles.Enabled := True;

        //========================================//
        CoInitialize(nil);
        FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
        FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
        FWbemObjectSet:= FWMIService.ExecQuery(Format('SELECT * FROM Win32_LogicalDisk Where Caption=%s',[QuotedStr(LeftStr(cbLogicalDrivers.Text,2))]),'WQL',wbemFlagForwardOnly);
        oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
        if oEnum.Next(1, FWbemObject, iValue) = 0 then
        begin
          FreeSize := FWbemObject.FreeSpace;
          FWbemObject:=Unassigned;
        end;

        hFile := CreateFile(PChar(cbLogicalDrivers.Text + '$00000000.tmp'), GENERIC_ALL, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
        if hFile <> INVALID_HANDLE_VALUE then
        begin
          CloseHandle(hFile);

          AssignFile(F,cbLogicalDrivers.Text + '$00000000.tmp');
          ReWrite(F);
          Reset(F,1);
          CBlock := 0;

          if cbLogicalDrivers.Text <> '' then
          begin
              repeat
                Randomize;
                Data  := RandomPassword(1024);
                BlockWrite(F,PChar(Data)^,RandomRange(1024,102400));
                CBlock := CBlock + 1;

              until (CBlock >= FreeSize - 2048);
          end;
          CloseFile(F);
        end;

     end;

  except

    Free_SWipe:= True;
    CoUninitialize;
    CloseFile(F);
    DeleteFile(cbLogicalDrivers.Text + '$00000000.tmp');
    // Erase MFT
    TDirectory.CreateDirectory(cbLogicalDrivers.Text + 'Eliminator');
    if System.SysUtils.DirectoryExists(cbLogicalDrivers.Text + 'Eliminator') then
    begin
      for I := 0 to 80000 do
      begin
        FileName := IntToStr(I) + '.elim';
        hFile := CreateFile(PChar(cbLogicalDrivers.Text + 'Eliminator\' + FileName),
                            GENERIC_ALL, FILE_SHARE_WRITE, nil, CREATE_ALWAYS,
                            FILE_ATTRIBUTE_NORMAL, 0);
        CloseHandle(hFile);
      end;


      FilesInDir := MyGetFiles(cbLogicalDrivers.Text + 'Eliminator','*.*');
      for I := 0 to High(FilesInDir) do
        DeleteFile(FilesInDir[I]);
      RemoveDir(cbLogicalDrivers.Text + 'Eliminator')
    end;
    FreeSpaceWipe.Stop;
    FreeSpaceWipe.Terminate;

  end;
end;

procedure TfrmMain.FreeSpaceWipeTerminate(Sender: TIdThreadComponent);
begin
   if Free_SWipe then
   begin
    Status.Panels[1].Text := 'Done !';
    MessageBoxA(self.Handle,'Free Space Wiped Successfully.','Info',MB_ICONINFORMATION);
    btnFreeSWipe.Enabled := True;
   end;
end;

procedure TfrmMain.FShredderRun(Sender: TIdThreadComponent);
begin
 try
   if ( OpenFile.Files.Count <> 0 ) or (lstWipe.Items.Count > 0)  then
   begin
     btnDestroyFiles.Enabled := False;
     ShredFileAndDelete;
     JobStatus := True;
   end else
       begin
         MessageBoxA(self.Handle,'No File/s Was Selected !','Error',MB_ICONERROR);
       end;
 finally
   btnDestroyFiles.Enabled := True;
   FShredder.Stop;
   FShredder.Terminate;
 end;
end;

procedure TfrmMain.FShredderTerminate(Sender: TIdThreadComponent);
begin
   if JobStatus then
   begin
    Status.Panels[1].Text := 'Done !';
    MessageBoxA(self.Handle,'You''r files wiped out successfully.','Info',MB_ICONINFORMATION);
    btnDestroyFiles.Enabled := True;
   end;
end;

function TfrmMain.MyGetFiles(const Path, Masks: string): TStringDynArray;
var
  MaskArray: TStringDynArray;
  Predicate: TDirectory.TFilterPredicate;
begin
  MaskArray := SplitString(Masks, ';');
  Predicate :=
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    var
      Mask: string;
    begin
      for Mask in MaskArray do
        if MatchesMask(SearchRec.Name, Mask) then
          exit(True);
      exit(False);
    end;
  Result := TDirectory.GetFiles(Path, Predicate);
end;


procedure TfrmMain.ShredFileAndDelete();
var
  F:file;
  CBlock, FSize:UInt64;
  s:String;
  I,Passes:Integer;
  FileHandle: THandle;
Const
  Buf : Byte = 0;
begin
      for I := lstWipe.Items.Count - 1  downto 0 do
      begin
           FileHandle := CreateFile(PChar(lstWipe.Items[I].Caption), GENERIC_READ,
                                    0, {exclusive}
                                    nil, {security}
                                    OPEN_EXISTING,
                                    FILE_ATTRIBUTE_NORMAL,
                                    0);

         FSize := GetFileSize(FileHandle,nil);
         CloseHandle(FileHandle);
         //=========================================//

         AssignFile(F,lstWipe.Items[I].Caption);
         Reset(F,1);
         //FSize := FileSize(F);
         CBlock := 0;
         if FSize <> 0 then
         begin

               case cbWipeMethods.ItemIndex of
                0:
                begin
                   Progress.Max := FSize;
                   // Write Random Data.
                   repeat
                    Randomize;
                    s  := RandomPassword(1024);
                    BlockWrite(F,PChar(s)^,length(s));
                    CBlock := CBlock + length(s);

                    Progress.Position := CBlock;
                   until (CBlock >= FSize);


                   // Empty File.
                   Rewrite(F);
                   Progress.Position := 0;
                end;
                1:
                begin
                   Progress.Max := FSize;
                   for Passes := 0 to 2 do
                   begin
                     CBlock := 0;
                     // Write Random Data.
                     repeat
                      Randomize;
                      s  := RandomPassword(1024);
                      BlockWrite(F,PChar(s)^,length(s));
                      CBlock := CBlock + length(s);

                      Progress.Position := CBlock;
                     until (CBlock >= FSize);

                     // Empty File.
                     Rewrite(F);
                     Progress.Position := 0;
                   end;
                end;
                2:
                begin
                   Progress.Max := FSize;
                   for Passes := 0 to 6 do
                   begin
                     CBlock := 0;
                     // Write Random Data.
                     repeat
                      Randomize;
                      s  := RandomPassword(1024);
                      BlockWrite(F,PChar(s)^,length(s));
                      CBlock := CBlock + length(s);

                      Progress.Position := CBlock;
                     until (CBlock >= FSize);

                     // Empty File.
                     Rewrite(F);
                     Progress.Position := 0;
                   end;
                end;
                3:
                begin
                   Progress.Max := FSize;
                   for Passes := 0 to 34 do
                   begin
                     CBlock := 0;
                     // Write Random Data.
                     repeat
                      Randomize;
                      s  := RandomPassword(1024);
                      BlockWrite(F,PChar(s)^,length(s));
                      CBlock := CBlock + length(s);


                      Progress.Position := CBlock;
                     until (CBlock >= FSize);

                     // Empty File.
                     Rewrite(F);
                     Progress.Position := 0;
                   end;
               end;
              end;
         end;

       CloseFile(F);

       Randomize;
       SetFileCreationTime(lstWipe.Items[I].Caption,RandomRange(100,25000));
       RenameFile(lstWipe.Items[I].Caption,ExtractFilePath(lstWipe.Items[I].Caption) + '$000000.tmp');
       DeleteFile(ExtractFilePath(lstWipe.Items[I].Caption) + '$000000.tmp');
       lstWipe.Items[I].Delete;
      end;
  FShredder.Terminate;
end;


procedure TfrmMain.btnAddfromDirClick(Sender: TObject);
var
 i:Integer;
 FilesInDir:TStringDynArray;
begin
  lstWipe.Clear;
  with TFileOpenDialog.Create(nil) do
  try
    Options := [fdoPickFolders];
    if Execute then
    begin
      if FileName <> '' then
       begin

          FilesInDir := TDirectory.GetFiles(FileName, '*.*', TSearchOption.soAllDirectories);
          for I := 0 to  High(FilesInDir) do
          begin
             lstWipe.AddItem(FilesInDir[I],nil);
          end;
       end;
    end;
  finally
    Free;
  end;
end;

procedure TfrmMain.btnDestroyFilesClick(Sender: TObject);
begin
 if MessageDlg('Are you sure ?',mtConfirmation,mbYesNo,0) = mrYes then
 begin
  JobStatus := False;
  FShredder.Start;
 end;
end;


end.
