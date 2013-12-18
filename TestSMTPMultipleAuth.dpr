program TestSMTPMultipleAuth;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, IdSMTP;

var
  IdSMTP1: TIdSMTP;
  I: Integer;
begin
  IdSMTP1 := TIdSMTP.Create(nil);
  try
    IdSMTP1.UseEhlo := True;
    IdSMTP1.AuthType := satDefault;
    IdSMTP1.Username := 'Test';
    IdSMTP1.Password := 'Blah';
    IdSMTP1.Host := 'localhost';
    IdSMTP1.Port := 25;
    IdSMTP1.Connect;
    for I := 1 to 10 do
      begin
        if IdSMTP1.Connected then
          begin
            try
              if IdSMTP1.Authenticate then Break;
            except
              IdSMTP1.Username := 'Test'+IntToStr(I);
              IdSMTP1.Password := 'Blah'+IntToStr(I);
            end;
          end;
      end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
