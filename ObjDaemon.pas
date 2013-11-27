unit ObjDaemon;

interface
uses MPEvent, MSEvent, daemon, Classes;
type
  TProcessor = class
  end;
  TProcessorClass = class of TProcessor;

procedure RegisterProcessor(const AProcessor: TProcessorClass);
procedure RegisterProcessors(const AProcessors: array of TProcessorClass);

function startup(var m: M_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;

implementation

type
  TMercuryRegGroups = class
  protected
    FProcessorClass: TList;
    FProcessorInstances: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProcessor(const AProcessor: TProcessorClass);
    procedure RegisterProcessors(const AProcessors: array of TProcessorClass);
  end;

var
  MercuryRegGroups: TMercuryRegGroups;

procedure RegisterProcessor(const AProcessor: TProcessorClass); // Class to register
begin
  MercuryRegGroups.RegisterProcessor(AProcessor);
end;

procedure RegisterProcessors(const AProcessors: array of TProcessorClass);
begin
  MercuryRegGroups.RegisterProcessors(AProcessors);
end;

function startup(var m: M_INTERFACE; var flags: UINT_32; name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;
begin
  Result := 1; // Non-zero to indicate success!
  try
    Result := MercuryRegGroups.startup(m, flags, name, param);
  except
    Result := 0;
  end;
end;

type
  TProcessorList = class(TList)
  end;

{ TMercuryRegGroups }

constructor TMercuryRegGroups.Create;
begin
  inherited Create;
  FProcessorClass := TProcessorList.Create;
  FProcessorInstances := TList.Create;
end;

destructor TMercuryRegGroups.Destroy;
begin
  FProcessorInstances.Free;
  FProcessorClass.Free;
  inherited;
end;

procedure TMercuryRegGroups.RegisterProcessor(const AProcessor: TProcessorClass);
begin
  FProcessorClass.Add(AProcessor);
end;

procedure TMercuryRegGroups.RegisterProcessors(
  const AProcessors: array of TProcessorClass);
var
  LProcessor: TProcessor;
begin
  for LProcessor in AProcessors do
    RegisterProcessor(LProcessor);
end;

initialization
  MercuryRegGroups := TMercuryRegGroups.Create;
finalization
  MercuryRegGroups.Free;
end.
