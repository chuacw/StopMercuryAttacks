unit DuplicatedIssue;
{.$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{.$STRONGLINKTYPES OFF}
// chuacw
{$WEAKLINKRTTI ON}

interface

procedure UniqueTest;

implementation
uses Winapi.Windows, System.SysUtils;

type
  TUniqueValue = record
    U1: Integer;
    U2: string;
  end;

var
  UniqueValue: TUniqueValue;

procedure UniqueTest; export;
var
  LParam: string;
  LPos: Integer;
begin
  LParam := GetModuleName(HInstance);  // returns the DLL name
  LPos := Pos('Forwarder', LParam);
  if (LPos<>0) then
    begin
      UniqueValue.U1 := $1111;
      UniqueValue.U2 := 'Hello World';
    end else
    begin
      UniqueValue.U1 := $2222;
      UniqueValue.U2 := 'This shouldn''t be Hello World';
    end;
end;

end.

