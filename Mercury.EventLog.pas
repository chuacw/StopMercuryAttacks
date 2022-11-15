// chuacw
unit Mercury.EventLog;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

interface
uses
  Winapi.Windows;

const
  EVENTLOG_SUCCESS = Winapi.Windows.EVENTLOG_SUCCESS;
  EVENTLOG_ERROR_TYPE = Winapi.Windows.EVENTLOG_ERROR_TYPE;
  EVENTLOG_WARNING_TYPE = Winapi.Windows.EVENTLOG_WARNING_TYPE;
  EVENTLOG_INFORMATION_TYPE = Winapi.Windows.EVENTLOG_INFORMATION_TYPE;

type
  TEventLogger = class
  private
    FAppName: string;
    FVersion, FNAME: string;
    FEventLog: Integer;
  public
    constructor Create(const Name: string);
    destructor Destroy; override;
    procedure LogMessage(const Message: string; EventType: DWord = EVENTLOG_INFORMATION_TYPE;
      Category: Integer = 0; ID: Integer = 0);
  end;

var
  EventLog: TEventLogger;

implementation
uses
  System.SysUtils;

type
  TFilenameVersion = class
  private
    FInfo: array of Char;
    FInfoSize: Cardinal;
    FFileName, FKey,

    FCompanyName,
      FDescription,
      FVersion,
      FInternalName,
      FLegalCopyright,
      FLegalTrademarks,
      FOriginalFilename,
      FProductName,
      FProductVersion,
      FComments: string;

    function GetVersion: string;
    function GetFileVersionString(const KeyName: string): string;
    function GetDescription: string;
    function GetNLSKey: string;
    function GetInternalName: string;
    function GetLegalCopyright: string;
    function GetLegalTrademarks: string;
    function GetCompanyName: string;
    function GetComments: string;
    function GetOriginalFilename: string;
    function GetProductName: string;
    function GetProductVersion: string;
  protected
    property Key: string read GetNLSKey;
  public
    constructor Create(const Filename: string);
    property Filename: string read FFileName;
    property CompanyName: string read GetCompanyName;
    property Description: string read GetDescription;
    property Version: string read GetVersion;
    property InternalName: string read GetInternalName;
    property LegalCopyright: string read GetLegalCopyright;
    property LegalTrademarks: string read GetLegalTrademarks;
    property OriginalFilename: string read GetOriginalFilename;
    property ProductName: string read GetProductName;
    property ProductVersion: string read GetProductVersion;
    property Comments: string read GetComments;
  end;

  { TFilenameVersion }

constructor TFilenameVersion.Create(const Filename: string);
begin
  inherited Create;
  FFileName := Filename;
end;

function TFilenameVersion.GetComments: string;
begin
  if FComments = '' then
    FComments := GetFileVersionString('Comments');
  Result := FCompanyName;
end;

function TFilenameVersion.GetCompanyName: string;
begin
  if FCompanyName = '' then
    FCompanyName := GetFileVersionString('CompanyName');
  Result := FCompanyName;
end;

function TFilenameVersion.GetDescription: string;
begin
  if FDescription = '' then
    FDescription := GetFileVersionString('FileDescription');
  Result := FDescription;
end;

function TFilenameVersion.GetFileVersionString(
  const KeyName: string): string;
var
  Temp: Cardinal;
  Buffer: PChar;
begin
  if FInfoSize = 0 then
    begin
      FInfoSize := GetFileVersionInfoSize(PChar(Filename), Temp);
      SetLength(FInfo, FInfoSize);
      GetFileVersionInfo(PChar(Filename), 0, FInfoSize, FInfo);
    end;
  if FInfoSize > 0 then
    begin
      if VerQueryValue(FInfo, PChar(Format('%s\%s', [Key, KeyName])),
        Pointer(Buffer), FInfoSize) then
        Result := Buffer;
    end;
end;

function TFilenameVersion.GetInternalName: string;
begin
  if FInternalName = '' then
    FInternalName := GetFileVersionString('InternalName');
  Result := FInternalName;
end;

function TFilenameVersion.GetLegalCopyright: string;
begin
  if FLegalCopyright = '' then
    FLegalCopyright := GetFileVersionString('LegalCopyright');
  Result := FLegalCopyright;
end;

function TFilenameVersion.GetLegalTrademarks: string;
begin
  if FLegalTrademarks = '' then
    FLegalTrademarks := GetFileVersionString('LegalTrademarks');
  Result := FLegalCopyright;
end;

function TFilenameVersion.GetNLSKey: string;
var
  P: Pointer;
  Len: Cardinal;
begin
  if FKey = '' then
    begin
      VerQueryValue(FInfo, '\VarFileInfo\Translation', P, Len);
      if Assigned(P) then
        FKey := Format('\StringFileInfo\%4.4x%4.4x', [LoWord(Longint(P^)), HiWord(Longint(P^))]);
    end;
  Result := FKey;
end;

function TFilenameVersion.GetOriginalFilename: string;
begin
  if FOriginalFilename = '' then
    FOriginalFilename := GetFileVersionString('OriginalFilename');
  Result := FOriginalFilename;
end;

function TFilenameVersion.GetProductName: string;
begin
  if FProductName = '' then
    FProductName := GetFileVersionString('ProductName');
  Result := FProductName;
end;

function TFilenameVersion.GetProductVersion: string;
begin
  if FProductVersion = '' then
    FProductVersion := GetFileVersionString('ProductVersion');
  Result := FProductVersion;
end;

function TFilenameVersion.GetVersion: string;
begin
  if FVersion = '' then
    FVersion := GetFileVersionString('FileVersion');
  Result := FVersion;
end;

{ TEventLogger }

constructor TEventLogger.Create(const Name: string);
var
  FilenameVersion: TFilenameVersion;
begin
  FNAME := Name;
  FAppName := ExtractFileName(ParamStr(0));
  FEventLog := 0;
  FilenameVersion := TFilenameVersion.Create(ParamStr(0));
  try
    FVersion := FilenameVersion.Version;
  finally
    FilenameVersion.Free;
  end;
end;

destructor TEventLogger.Destroy;
begin
  if FEventLog <> 0 then
    DeregisterEventSource(FEventLog);
  inherited;
end;

procedure TEventLogger.LogMessage(const Message: string; EventType: DWord; Category, ID: Integer);
var
  P: Pointer;
begin
  P := PChar(Format('%s v%s PID=%u,%2:x: %s', [FAppName, FVersion, GetCurrentProcessId, Message]));
  if FEventLog = 0 then
    FEventLog := RegisterEventSource(nil, PChar(FNAME));
  ReportEvent(FEventLog, EventType, Category, ID, nil, 1, 0,
    @P, nil);
end;

end.

