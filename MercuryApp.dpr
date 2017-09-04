program MercuryApp;
// chuacw
{$APPTYPE CONSOLE}
{$R *.res}
uses
  System.SysUtils,
  System.Classes;

procedure DoSomething(const L: UnicodeString); overload;
begin
  WriteLn(L);
end;

procedure DoSomething(const A: AnsiString); overload;
begin
  WriteLn(A);
end;

var
  ALine: AnsiString;
  ULine: UnicodeString;
  List: TStringList;
  Count: Integer;
  X: string;
  Xs: array of string;
begin
  ReportMemoryLeaksOnShutdown := True;

  for X in Xs do
    WriteLn(X);

  Count := 0;

  List := TStringList.Create;
  try
    List.Add('Hello world');
    List.Add('Goodbye!');

    for ALine in List do // Compiler warninig Implicit string cast with potential data loss from 'string' to 'AnsiString'
      DoSomething(ALine);


    for ULine in List do
      DoSomething(ULine);

  // String cast to eliminate warning
    for ALine in List do // But goes into an infinite loop!!!
      begin
        WriteLn(ALine);
        Inc(Count);
      end;
  finally
    List.Free;
  end;

end.
