unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl,IdBaseComponent, IdThreadComponent;

type
  TfrmMain = class(TForm)
    btnSelectFiles: TButton;
    btnDestroyFiles: TButton;
    OpenFile: TOpenDialog;
    Shredder_Thread: TIdThreadComponent;
    Status: TLabel;
    lblStatus: TLabel;
    procedure btnSelectFilesClick(Sender: TObject);
    procedure btnDestroyFilesClick(Sender: TObject);
    procedure Shredder_ThreadRun(Sender: TIdThreadComponent);
    procedure Shredder_ThreadTerminate(Sender: TIdThreadComponent);
    procedure ShredFileAndDelete(ShredFilePath:String);
    procedure ListFileDir(Path: string; FileList: TStrings);
    function RandomPassword(PLen: Integer): string;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  JobStatus:Boolean;

implementation

{$R *.dfm}

procedure TfrmMain.btnSelectFilesClick(Sender: TObject);
begin
 OpenFile.Execute(self.Handle);
end;

procedure TfrmMain.ListFileDir(Path: string; FileList: TStrings);
var
  SR: TSearchRec;
begin
  if FindFirst(Path + '*.*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        FileList.Add(SR.Name);
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
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

procedure TfrmMain.Shredder_ThreadRun(Sender: TIdThreadComponent);
var
 i:Integer;
begin
 try
   if OpenFile.Files.Count <> 0  then
   begin
     for I := 0 to OpenFile.Files.Count - 1  do
     begin
      ShredFileAndDelete(OpenFile.Files[I]);
     end;
     JobStatus := True;
   end else
       begin
         MessageBoxA(self.Handle,'No File Was Selected !','Error',MB_ICONERROR);
       end;
 finally
   Shredder_Thread.Stop;
   Shredder_Thread.Terminate;
 end;
end;

procedure TfrmMain.Shredder_ThreadTerminate(Sender: TIdThreadComponent);
begin
 if JobStatus then
   Status.Caption := 'Done !'
end;

procedure TfrmMain.ShredFileAndDelete(ShredFilePath: String);
var
  F:file;
  CBlock, FSize:Cardinal;
  s:String;
begin
 AssignFile(F,ShredFilePath);
 Reset(F,1);
 FSize := FileSize(F);
 CBlock := 0;
 if FSize <> 0 then
 begin
   repeat
    Randomize;
    s  := RandomPassword((FSize div 2));
    BlockWrite(F,PChar(s)^,(FSize div 2));
    CBlock := CBlock + (FSize div 2);
   until (CBlock >= FSize);
 end;
 CloseFile(F);
 RenameFile(ShredFilePath,ExtractFilePath(ShredFilePath) + '$000000.tmp');
 DeleteFile(ExtractFilePath(ShredFilePath) + '$000000.tmp');
end;


procedure TfrmMain.btnDestroyFilesClick(Sender: TObject);
begin
 JobStatus := False;
 Shredder_Thread.Start;
end;


end.
