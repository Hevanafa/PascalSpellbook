{
  Title: Split string and parse int
  Author: Hevanafa
  Description:
  Category: Basics
  Requires: Classes, SysUtils
  Tags: beginner, output
  Website: https://github.com/Hevanafa/PascalSpellbook
  Licence: MIT
  Version: 0.1
}

uses Classes, SysUtils;

var
  line: string;
  tokens: TStringArray;
  numbers: array of longint;
  a: word;
begin
  readln(line);
  tokens := line.split(' ');
  SetLength(numbers, length(tokens));

  for a:=0 to high(tokens) do
    numbers[a] := strtoint(tokens[a]);
end.
