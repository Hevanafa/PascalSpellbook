unit Unit1;

{$Mode ObjFPC}
{$H+}
{$Notes OFF}

interface

uses
  Classes, SysUtils, FGL,
  Forms, Controls, Graphics, Dialogs, StdCtrls, SynHighlighterPas, SynEdit;

type

  { TSnippetMetadata }

  TSnippetMetadata = class
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
  end;

  { TSnippet }

  TSnippet = class
  private
    fSourceCode: string;
    fMetadata: TSnippetMetadata;
  public
    procedure LoadFromCode(const sourceCode: string);
    property Metadata: TSnippetMetadata read fMetadata;
    property SourceCode: string read fSourceCode;
    destructor Destroy; override;
  end;

  TSnippetList = specialize TFPGObjectList<TSnippet>;

  { TForm1 }

  TForm1 = class(TForm)
    SnippetListBox: TListBox;
    SynEdit1: TSynEdit;
    SynFreePascalSyn1: TSynFreePascalSyn;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SnippetListBoxSelectionChange(Sender: TObject; User: boolean);

  private
    snippetList: TSnippetList;

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

{ TSnippetMetadata }

procedure TSnippetMetadata.LoadFromCode(const sourceCode: string);
var
  lines: TStringArray;
  line, trimmed: string;
  beginMetadata: boolean;
begin
  lines := sourceCode.Split(LineEnding);

  for line in lines do begin
    trimmed := Trim(line);

    if trimmed = '{' then beginMetadata := true;
    if trimmed = '}' then beginMetadata := false;

    if not beginMetadata then continue;

    if trimmed.ToLower.Contains('title:') then
      self.Title := trim(copy(trimmed, 7));
    if trimmed.ToLower.Contains('author:') then
      self.Author := trim(copy(trimmed, 7));

    if trimmed.ToLower.Contains('description:') then
      self.Description := trim(copy(trimmed, 7));
    if trimmed.ToLower.Contains('category:') then
      self.Category := trim(copy(trimmed, 7));

    if trimmed.ToLower.Contains('requires:') then
      self.Requires := trim(copy(trimmed, 7));
    if trimmed.ToLower.Contains('tags:') then
      self.Tags := trim(copy(trimmed, 7));

    if trimmed.ToLower.Contains('website:') then
      self.Website := trim(copy(trimmed, 7));
    if trimmed.ToLower.Contains('licence:') then
      self.Licence := trim(copy(trimmed, 7));

    if trimmed.ToLower.Contains('version:') then
      self.Version := trim(copy(trimmed, 7));
  end;
end;

{ TSnippet }

procedure TSnippet.LoadFromCode(const sourceCode: string);
begin
  fSourceCode:= sourceCode;

  fMetadata := TSnippetMetadata.create;
  fMetadata.LoadFromCode(sourceCode)
end;

destructor TSnippet.Destroy;
begin
  fMetadata.free;
  inherited Destroy
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

  snippetList := TSnippetList.create;
  reader := TStringList.create;

  filelist := FindAllFiles(SnippetsDir, '*.pas', false);

  for path in filelist do begin
    reader.LoadFromFile(path);

    snippet := TSnippet.create;
    snippet.LoadFromCode(reader.text);

    snippetList.Add(snippet);
    SnippetListBox.AddItem(snippet.fMetadata.title, nil);

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

