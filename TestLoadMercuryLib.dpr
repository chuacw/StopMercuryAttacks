program TestLoadMercuryLib;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Winapi.Windows;

procedure TestForwarder;
var
  LHandle1, LHandle2, LHandle3: THandle;
  LUniqueTest1, LUniqueTest2: TProcedure;
begin
  LHandle1 := LoadLibrary('Mercury.Daemons.Forward.dll');
  LHandle2 := LoadLibrary('Mercury.Daemons.Forwarder2.dll');
  LHandle3 := LoadLibrary('C:\MERCURY\DAEMONS\Mercury.Daemons.Forwarder.dll');

  LUniqueTest1 := GetProcAddress(LHandle1, 'UniqueTest');
  LUniqueTest2 := GetProcAddress(LHandle2, 'UniqueTest');

  if Assigned(LUniqueTest1) then
    LUniqueTest1;
  if Assigned(LUniqueTest2) then
    LUniqueTest2;

  if Assigned(LUniqueTest1) then
    LUniqueTest1;
  if Assigned(LUniqueTest2) then
    LUniqueTest2;

  FreeLibrary(LHandle3);
  FreeLibrary(LHandle2);
  FreeLibrary(LHandle1);
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  TestForwarder;
end.
