unit Unit1;

{$Mode ObjFPC}
{$H+}
{$Notes OFF}

interface

uses
  Classes, SysUtils, FGL,
  Forms, Controls, Graphics, Dialogs, StdCtrls, SynHighlighterPas, SynEdit;

type

  { TSnippet }

  TSnippet = class
  private
    fSourceCode: string;

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

    procedure LoadFromCode(const sourceCode: string);

    property SourceCode: string read fSourceCode;
  end;

  TMetadataList = specialize TFPGObjectList<TSnippet>;

  { TForm1 }

  TForm1 = class(TForm)
    SnippetListBox: TListBox;
    SynEdit1: TSynEdit;
    SynFreePascalSyn1: TSynFreePascalSyn;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SnippetListBoxSelectionChange(Sender: TObject; User: boolean);

  private
    snippetList: TMetadataList;

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

{ TSnippet }

procedure TSnippet.LoadFromCode(const sourceCode: string);
var
  lines: TStringArray;
  line, trimmed: string;
  beginMetadata: boolean;
begin
  fSourceCode:= sourceCode;

  lines := sourceCode.Split(LineEnding);

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
  snippet: TSnippet;
begin
  SynEdit1.clear;

  snippetList := TMetadataList.create;
  reader := TStringList.create;

  filelist := FindAllFiles(SnippetsDir, '*.pas', false);

  for path in filelist do begin
    reader.LoadFromFile(path);

    snippet := TSnippet.create;
    snippet.LoadFromCode(reader.text);

    snippetList.Add(snippet);
    SnippetListBox.AddItem(snippet.title, nil);

    reader.free
  end;

  filelist.free
end;

procedure TForm1.SnippetListBoxSelectionChange(Sender: TObject; User: boolean);
begin
  if SnippetListBox.ItemIndex = -1 then exit;

  SynEdit1.Text := snippetList[SnippetListBox.ItemIndex].SourceCode
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  snippetList.free
end;

end.

