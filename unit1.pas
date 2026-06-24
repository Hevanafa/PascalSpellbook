unit Unit1;

{$Mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils,
  Forms, Controls, Graphics, Dialogs, StdCtrls, SynHighlighterPas, SynEdit;

type

  { TForm1 }

  TForm1 = class(TForm)
    SnippetList: TListBox;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
var
  searchRec: TSearchRec;
  targetDir: string;
begin
  targetDir := '.\snippets\';

  if FindFirst(targetDir + '*.pas', faAnyFile, searchRec) = 0 then begin
    repeat
      if (searchRec.Name <> '.') and (searchRec.Name <> '..') then begin
        if (searchRec.Attr and faDirectory) = 0 then
          SnippetList.AddItem(searchRec.name, nil);
      end;
    until FindNext(searchRec) <> 0;

    FindClose(searchRec)
  end;
end;

end.

