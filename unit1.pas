unit Unit1;

{$Mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, FGL,
  Forms, Controls, Graphics, Dialogs, StdCtrls, SynHighlighterPas, SynEdit;

type

  { TMetadata }

  TMetadata = class
  public
    Title: string;
    Author: string;
    Description: string;
    Category: string;
    Requires: string;
    Tags: string;
    Website: string;
    Licence: string;
    Version: string;

    procedure LoadFromCode(const code: string);
  end;

  TMetadataList = specialize TFPGObjectList<TMetadata>;

  { TForm1 }

  TForm1 = class(TForm)
    SnippetList: TListBox;
    SynEdit1: TSynEdit;
    SynFreePascalSyn1: TSynFreePascalSyn;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private
    metadataList: TMetadataList;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  FileUtil;

const
  SnippetsDir = '.\snippets\';

{ TMetadata }

procedure TMetadata.LoadFromCode(const code: string);
var
  lines: TStringArray;
  line, trimmed: string;
  beginMetadata: boolean;
begin
  lines := code.Split(LineEnding);

  for line in lines do begin
    trimmed := Trim(line);

    if trimmed = '{' then beginMetadata := true;
    if trimmed = '}' then beginMetadata := false;

    if not beginMetadata then continue;

    if trimmed.ToLower.Contains('title:') then
      self.Title := trim(copy(trimmed, 7));
  end;
end;

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
var
  filelist: TStringList;
  path: string;
  reader: TStringList;
  metadata: TMetadata;
begin
  metadataList := TMetadataList.create;
  reader := TStringList.create;

  filelist := FindAllFiles(SnippetsDir, '*.pas', false);

  for path in filelist do begin
    reader.LoadFromFile(path);

    metadata := TMetadata.create;
    metadata.LoadFromCode(reader.text);

    SnippetList.AddItem(metadata.title, nil);

    metadata.free;
    reader.free
  end;

  filelist.free
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  metadataList.free
end;

end.

