unit unitSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Buttons, ValEdit, unitData;

type

  { TFormSettings }

  TFormSettings = class(TForm)
    btnRefreshCongregations: TBitBtn;
    ListViewCongregations: TListView;
    PageControl1: TPageControl;
    PanelCongregation: TPanel;
    TabSheetCongregation: TTabSheet;
    ValueListEditorCongregation: TValueListEditor;
    procedure btnRefreshCongregationsClick(Sender: TObject);
    procedure ListViewCongregationsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private

  public

  end;

implementation

{$R *.lfm}

{ TFormSettings }

procedure TFormSettings.btnRefreshCongregationsClick(Sender: TObject);
var
  i: Integer;
  li: TListItem;
begin
  dataModuleMain.congregations.refresh;
  ListViewCongregations.Items.Clear;
  for i:=0 to Length(DataModuleMain.congregations.Items) - 1 do
  begin
    li:=ListViewCongregations.Items.Add;
    li.Caption:=DataModuleMain.congregations.Items[i].id;
    li.SubItems.add(DataModuleMain.congregations.Items[i].name);
  end;

end;

procedure TFormSettings.ListViewCongregationsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  i: integer;
begin
  ValueListEditorCongregation.Clear;
  for i:=0 to Item.SubItems.Count - 1 do
  begin
    ValueListEditorCongregation.InsertRow(
        ListViewCongregations.Columns[i+1].Caption,
        Item.SubItems[i],
        true);
  end;
end;

end.

