unit Mercury.Forms;

interface
uses
  System.SysUtils,
  System.Classes;

type
  /// <summary>Component to use services like an application module</summary>
  TMercuryApplication = class(TComponent)
  private
    class constructor Create;
    procedure OnExceptionHandler(Sender: TObject);
  protected
    /// <summary>Exception Handler for non user managed exceptions</summary>
    /// <remarks>Exceptions not managed by the user will be shown in the android logcat</remarks>
    procedure DoHandleException(E: Exception); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // The following uses the current behaviour of the IDE module manager
    /// <summary>Create an Instance of the class type from InstanceClass param</summary>
    procedure CreateForm(InstanceClass: TComponentClass; var Reference); virtual;
    /// <summary>Initializes the service application</summary>
    procedure Initialize; virtual;
    /// <summary>Main loop of the application service</summary>
    procedure Run; virtual;
  end;

var
  /// <summary>Global var to acces to the Application Service</summary>
  Application: TMercuryApplication = nil;

implementation

constructor TMercuryApplication.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if not Assigned(System.Classes.ApplicationHandleException) then
    System.Classes.ApplicationHandleException := OnExceptionHandler;
end;

class constructor TMercuryApplication.Create;
begin
  Application := TMercuryApplication.Create(nil);
end;

procedure TMercuryApplication.CreateForm(InstanceClass: TComponentClass; var Reference);
begin
  if InstanceClass.InheritsFrom(TDataModule) then
//  InstanceClass.InheritsFrom(TAndroidBaseService) then
  begin
    try
      TComponent(Reference) := InstanceClass.Create(Self);
//      if InstanceClass.InheritsFrom(TAndroidService) then
//        ; // TAndroidServiceCallbacks.FService := TAndroidService(Reference);
//      if InstanceClass.InheritsFrom(TAndroidIntentService) then
//        ; // TAndroidServiceCallbacks.FIntentService := TAndroidIntentService(Reference);
    except
      TComponent(Reference) := nil;
      raise;
    end;
  end;
end;

destructor TMercuryApplication.Destroy;
begin

  inherited Destroy;
end;

procedure TMercuryApplication.DoHandleException(E: Exception);
begin
end;

procedure TMercuryApplication.Initialize;
begin

end;

procedure TMercuryApplication.OnExceptionHandler(Sender: TObject);
begin
  DoHandleException(Exception(ExceptObject));
end;

procedure TMercuryApplication.Run;
begin

end;


end.
