/// <summary>
/// The purpose of this unit is to unify the SMTP and the POP startup so
/// that there is only a single startup routine. By registering the callbacks,
/// the idea is to provide the ability for the any registered callbacks to be called
/// by the startup routine.
/// </summary>
unit Mercury.Callbacks; experimental;

interface
uses Mercury.Daemon;

function startup(m: PM_INTERFACE; var Flags: UINT_32; Name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;

type
  TStartupCallback = function(m: PM_INTERFACE; var Flags: UINT_32; const Name, Param: string): Smallint;
  TStartupCallbackRef = reference to procedure(m: PM_INTERFACE; var Flags: UINT_32; const Name, Param: string; var CallbackResult: Smallint);

///<summary>Place a call to this routine within the initialization of the unit's block.</summary>
procedure RegisterStartupCallback(AStartupCallback: TStartupCallback); overload;

///<summary>Place a call to this routine within the initialization of the unit's block.</summary>
procedure RegisterStartupCallback(const AStartupCallbackRef: TStartupCallbackRef); overload;

implementation
uses System.Generics.Collections;
var
  GList: TList<TStartupCallbackRef>;

function startup(m: PM_INTERFACE; var Flags: UINT_32; Name: PAnsiChar;
  param: PAnsiChar): Smallint; cdecl; export;
var
  ACallback: TStartupCallbackRef;
begin
  Result := 1;
  for ACallback in GList do
    begin
      try
        ACallback(m, Flags, string(Name), string(Param), Result);
      except
      end;
    end;
  GList.Free;
  GList := nil;
end;

procedure RegisterStartupCallback(AStartupCallback: TStartupCallback);
begin
  RegisterStartupCallback(function(m: PM_INTERFACE; var Flags: UINT_32; const Name, Param: string): Smallint
    begin
      Result := AStartupCallback(m, Flags, Name, Param);
    end
  );
end;

procedure RegisterStartupCallback(const AStartupCallbackRef: TStartupCallbackRef);
begin
  if not Assigned(GList) then
    GList := TList<TStartupCallbackRef>.Create;
  GList.Add(AStartupCallbackRef);
end;

end.
