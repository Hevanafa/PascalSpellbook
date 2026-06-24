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
    { fRawText: string; }
    fSourceCode: string;
    fMetadata: TSnippetMetadata;
    fFilename: string;
  public
    property Metadata: TSnippetMetadata read fMetadata;
    { property RawText: string read fRawText; }
    property SourceCode: string read fSourceCode;
    property Filename: string read fFilename write fFilename;

    procedure LoadFromCode(const aRawText: string);
    destructor Destroy; override;
  end;

  TSnippetList = specialize TFPGObjectList<TSnippet>;

  { TForm1 }

  TForm1 = class(TForm)
    CopySnippetButton: TButton;
    FilenameLabel: TLabel;
    SnippetListBox: TListBox;
    SynEdit1: TSynEdit;
    SynFreePascalSyn1: TSynFreePascalSyn;
    procedure CopySnippetButtonClick(Sender: TObject);
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
  Clipbrd, FileUtil, Windows;

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
      self.Title := trim(copy(trimmed, length('title:') + 1));
    if trimmed.ToLower.Contains('author:') then
      self.Author := trim(copy(trimmed, length('author:') + 1));

    if trimmed.ToLower.Contains('description:') then
      self.Description := trim(copy(trimmed, length('description:') + 1));
    if trimmed.ToLower.Contains('category:') then
      self.Category := trim(copy(trimmed, length('category:') + 1));

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

procedure TSnippet.LoadFromCode(const aRawText: string);
var
  lines: TStringArray;
  line: string;
  chomped: string;
  passedMetadata: boolean;
  skipFirstLines: boolean;
begin
  { fRawText:= aRawText; }
  fMetadata := TSnippetMetadata.create;
  fMetadata.LoadFromCode(aRawText);

  lines := aRawText.split(#10);

  passedMetadata := false;
  skipFirstLines := true;

  fSourceCode := '';

  for line in lines do begin
    chomped := line.TrimRight;

    if trim(line) = '}' then begin
      passedMetadata := true;
      continue
    end;

    if not passedMetadata then continue;

    if trim(line) <> '' then
      skipFirstLines := false;

    if skipFirstLines then continue;

    fSourceCode := fSourceCode + chomped + LineEnding
  end;
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
    snippet.Filename := ExtractFileName(path);

    snippetList.Add(snippet);
    SnippetListBox.AddItem(snippet.fMetadata.title, nil);

    reader.free
  end;

  filelist.free
end;

procedure TForm1.SnippetListBoxSelectionChange(Sender: TObject; User: boolean);
begin
  if SnippetListBox.ItemIndex = -1 then exit;

  with snippetList[SnippetListBox.ItemIndex] do begin
    FilenameLabel.caption := 'Filename: ' + Filename;
    SynEdit1.Text := SourceCode;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  snippetList.free
end;

procedure TForm1.CopySnippetButtonClick(Sender: TObject);
begin
  if SynEdit1.Text = '' then begin
    MessageBox(0, 'Nothing to copy!', 'Copy Snippet', MB_OK);
    exit
  end;

  Clipboard.AsText := SynEdit1.text;
  MessageBox(0, 'Copied to clipboard!', 'Copy Snippet', MB_OK or MB_ICONINFORMATION);
end;

end.

