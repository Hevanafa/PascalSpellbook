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

    constructor FromCode(const code: string);
  end;

  TMetadataList = specialize TFPGObjectList<TMetadata>;

  { TForm1 }

  TForm1 = class(TForm)
    SnippetList: TListBox;
    procedure FormShow(Sender: TObject);

  private
    metadataList: TMetadataList;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}


const
  SnippetsDir = '.\snippets\';

{ TMetadata }

constructor TMetadata.FromCode(const code: string);
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
  searchRec: TSearchRec;
  targetDir: string;
  filename: string;
  reader: TStringList;
  metadata: TMetadata;
begin
  targetDir := SnippetsDir;

  metadataList := TMetadataList.create;
  reader := TStringList.create;

  if FindFirst(targetDir + '*.pas', faAnyFile, searchRec) = 0 then begin
    repeat
      if (searchRec.Name <> '.') and (searchRec.Name <> '..') then begin
        if (searchRec.Attr and faDirectory) = 0 then begin
          filename := searchRec.name;
          reader.LoadFromFile(SnippetsDir + filename);
          metadata := TMetadata.FromCode(reader.text);

          SnippetList.AddItem(metadata.title, nil);

          reader.free
        end;
      end;
    until FindNext(searchRec) <> 0;

    FindClose(searchRec)
  end;
end;

end.

