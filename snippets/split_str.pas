{
  Title: Split string to tokens
  Author: Hevanafa
  Description:
  Category: Basics
  Requires: SysUtils
  Tags: beginner, output
  Website: https://github.com/Hevanafa/PascalSpellbook
  Licence: MIT
  Version: 0.1
}

uses
  SysUtils;

var
  line: string;
  strary: TStringArray;
  s: string;
begin
  ReadLn(line);
  strary := line.split(' ');
  
  for s in strary do begin
    { do stuff }
  end;
end;