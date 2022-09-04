unit unitMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls;

type

  { TFormMain }

  TFormMain = class(TForm)
    ImageList1: TImageList;
    ListView1: TListView;
    PageControl1: TPageControl;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    procedure CoolBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TFormMain.PageControl1Change(Sender: TObject);
begin

end;

procedure TFormMain.CoolBar1Change(Sender: TObject);
begin

end;

end.

