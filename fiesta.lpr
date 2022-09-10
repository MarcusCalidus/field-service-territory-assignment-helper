program fiesta;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, unitData, unitMain, unitSettings, unitLogin, System.UITypes;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TDataModuleMain, DataModuleMain);
  FormLogin:=TFormLogin.Create(Application);
  if FormLogin.ShowModal=mrOK then
  begin
    Application.CreateForm(TFormMain, FormMain);
    Application.Run;
  end;
end.

