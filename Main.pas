unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl,IdBaseComponent, IdThreadComponent;

type
  TfrmMain = class(TForm)
    btnSelectFiles: TButton;
    btnDestroyFiles: TButton;
    OpenFile: TOpenDialog;
    Shredder_Thread: TIdThreadComponent;
    Status: TLabel;
    lblStatus: TLabel;
    chSecureLayer: TCheckBox;
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

implementation

{$R *.dfm}

////////////////////////////////////////////////////////////////////////////////

procedure TfrmMain.btnSelectFilesClick(Sender: TObject);
var
 I:integer;
 MyList:TStringList;
begin
  if OpenFile.Execute(self.Handle) then
  begin
    if OpenFile.Files.Count <> 0 then
    begin
        // File Selected
    end;
  end;
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
  str    := '!@#$%^&*()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
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
   for I := 0 to OpenFile.Files.Count - 1  do
   begin
    ShredFileAndDelete(OpenFile.Files[I]);
   end;
 finally
   Shredder_Thread.Terminate;
 end;
end;

procedure TfrmMain.Shredder_ThreadTerminate(Sender: TIdThreadComponent);
begin
 Status.Caption := 'Done !';
end;

procedure TfrmMain.ShredFileAndDelete(ShredFilePath: String);
const
  BufferSize = 2048;
  NPasses = 1;
  FileJunk: Array[0..5] of Integer = ($FF, $FF, $FF, $FF, $FF, $FF);
var
  F:file;
  I,PosCount:Integer;
  CPass, CBlock, FSize:Integer;
  MS:TMemoryStream;
  fs: TFileStream;
  s:String;
  F_Size:Int64;
begin
  if chSecureLayer.Checked then
  begin
    fs := TFileStream.Create(ShredFilePath, fmOpenWrite);
    PosCount := 0;
    repeat
     fs.Position := PosCount;
     Randomize;
     s  := RandomPassword(2);
     //fs.Write(s, Length(s));

     fs.Write(PChar(s)^, Length(s));
     PosCount := PosCount + (fs.Size div 2);

    until(PosCount > fs.Size);
    fs.Free;
  end;

  AssignFile(F,ShredFilePath);
  Reset(F,1);
  FSize := FileSize(F);
  for CPass := 0 to NPasses do
  begin
   for CBlock := 1 to Fsize div BufferSize do
   begin
    BlockWrite(F,FileJunk[CBlock],BufferSize);
   end;
  end;
  CloseFile(F);
  RenameFile(ShredFilePath,ExtractFilePath(ShredFilePath) + '$000000.tmp');
  DeleteFile(ExtractFilePath(ShredFilePath) + '$000000.tmp');
end;


procedure TfrmMain.btnDestroyFilesClick(Sender: TObject);
begin
 Shredder_Thread.Start;
end;


end.
