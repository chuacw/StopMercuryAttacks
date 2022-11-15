program TestMercurySMTPBlacklistConfigurator;

uses
  Vcl.Forms, System.Classes, System.SysUtils,
  System.StrUtils, System.Types, IdDNSResolver,
  Mercury.SMTP.ConfigureBlacklist in 'Mercury.SMTP.ConfigureBlacklist.pas' {frmBlacklist};

{$R *.res}

procedure TestBlacklist;
var
  Blacklist: TStrings;
  I: Integer;
begin
  ReportMemoryLeaksOnShutdown := True;
  Blacklist := TStringList.Create;
  for I := 1 to 50 do
    Blacklist.Add(IntToStr(I));

  frmBlacklist := TfrmBlacklist.Create(nil);
  frmBlacklist.Blacklist := Blacklist;
  frmBlacklist.ShowModal;
  frmBlacklist.Free;

  Blacklist.Free;
end;

function ReverseIP(const IPAddress: string): string;
var
  I: Integer;
  LIPComponents: TStringDynArray;
begin
  LIPComponents := SplitString(IPAddress, '.');
  for I := High(LIPComponents) downto Low(LIPComponents)+1 do
    Result := Result + LIPComponents[I] + '.';
  Result := Result + LIPComponents[Low(LIPComponents)];
end;

/// <summary> Checks if an IP address is blacklisted in the SORBS database.
/// </summary>
/// <param name='IPAddress'>
/// The IPv4 address to check if it's blacklisted
/// </param>
/// <returns> True if blacklisted, false otherwise.
/// </returns>
function IsSORBSBlacklisted(const IPAddress: string): Boolean;
var
  LReversedIPAddress, LQuery: string;
  LDNSResolver: TIdDNSResolver;
begin
  LReversedIPAddress := ReverseIP(IPAddress);
  LQuery := Format('%s.dnsbl.sorbs.net', [LReversedIPAddress]);
  LDNSResolver := TIdDNSResolver.Create(nil);
  try
    LDNSResolver.Host := '8.8.8.8';
    LDNSResolver.QueryType := [qtSTAR];
    try
      LDNSResolver.Resolve(LQuery);
      Result := LDNSResolver.QueryResult.Count > 0;
    except
      Result := True; // Blacklist by default
    end;
  finally
    LDNSResolver.Free;
  end;
end;

function IsDomainBlacklisted(const ADomain: string): Boolean;
var
  LQuery: string;
  LDNSResolver: TIdDNSResolver;
begin
  LQuery := Format('%s.dnsbl.sorbs.net', [ADomain]);
  LDNSResolver := TIdDNSResolver.Create(nil);
  try
    LDNSResolver.Host := '8.8.8.8';
    LDNSResolver.QueryType := [qtSTAR];
    LDNSResolver.Resolve(LQuery);
    Result := LDNSResolver.QueryResult.Count > 0;
  finally
    LDNSResolver.Free;
  end;
end;

begin
  IsDomainBlacklisted('bret.lotiones.club');
  IsSORBSBlacklisted('200.38.231.80');
end.
