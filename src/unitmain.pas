unit unitMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, UnitSettings, UnitData;

type

  { TFormMain }

  TFormMain = class(TForm)
    btnShowSettings: TBitBtn;
    ImageList1: TImageList;
    ListView1: TListView;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    procedure btnShowSettingsClick(Sender: TObject);
    procedure CoolBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
begin

end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  btnShowSettings.enabled:=DataModuleMain.currentUser.is_admin <> 0;
end;

procedure TFormMain.PageControl1Change(Sender: TObject);
begin

end;

procedure TFormMain.CoolBar1Change(Sender: TObject);
begin

end;

procedure TFormMain.btnShowSettingsClick(Sender: TObject);
var
  formSettings: TFormSettings;
begin
  formSettings:=TFormSettings.Create(self);
  formSettings.ShowModal;
  formSettings.Free;
end;

end.

