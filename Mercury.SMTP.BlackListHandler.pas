unit Mercury.SMTP.BlackListHandler;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface
uses
  System.Generics.Collections;

type
  TBlacklist = class
  protected
    FBackingFile: string;
    FDirty: Boolean;
    FCount: Integer;
    FList: TList<AnsiString>;
  public
    constructor Create(const ABackingFile: string);
    destructor Destroy; override;
    procedure Load;
    procedure Save(SaveIfDirty: Boolean = True);
  end;

implementation
uses
  System.SysUtils;

{ TBlacklist }

constructor TBlacklist.Create(const ABackingFile: string);
begin
  inherited Create;
  FBackingFile := ABackingFile;
  FDirty := False;
end;

destructor TBlacklist.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TBlacklist.Load;
var
  F: TextFile;
  Line: AnsiString;
begin
  AssignFile(F, FBackingFile);
  Reset(F);
  while not eof(F) do
    begin
      ReadLn(F, Line);
      if not FList.Contains(Line) then
        FList.Add(Line) else
        FDirty := True;
    end;
  FCount := FList.Count;
  CloseFile(F);
end;

procedure TBlacklist.Save(SaveIfDirty: Boolean);
begin
end;

end.
