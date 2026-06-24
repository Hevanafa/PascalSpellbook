{
  Title: Parse Integer
  Author: Hevanafa
  Description:
  Category: Basics
  Requires: (none)
  Tags: beginner, output
  Website: https://github.com/Hevanafa/PascalSpellbook
  Licence: MIT
  Version: 0.1
}

uses
  SysUtils;

var
  line: string;
  n: longint;
begin
  readln(line);
  n := strtoint(line);

  writeln(n);

  flush(stderr); flush(stdout)
end.
