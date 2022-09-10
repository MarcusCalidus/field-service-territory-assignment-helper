unit unitSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Buttons, ValEdit, StdCtrls, unitData;

type

  { TFormSettings }

  TFormSettings = class(TForm)
    btnAddUser: TBitBtn;
    btnAddTerritory: TBitBtn;
    btnDeleteUser: TBitBtn;
    btnDeleteTerritory: TBitBtn;
    btnRefreshUsers: TBitBtn;
    btnRefreshTerritories: TBitBtn;
    btnSaveCongregation: TBitBtn;
    btnRefreshCongregations: TBitBtn;
    btnAddCongregation: TBitBtn;
    btnDeleteCongregation: TBitBtn;
    btnSaveCongregation1: TBitBtn;
    btnSaveTerritory: TBitBtn;
    ImageList1: TImageList;
    ListViewCongregations: TListView;
    Panel4: TPanel;
    PanelCongregation1: TPanel;
    PanelUserTitle1: TPanel;
    v: TListView;
    ListViewTerritories: TListView;
    PageControl1: TPageControl;
    Panel3: TPanel;
    PanelUserToolbar: TPanel;
    PanelTerritoryTitle: TPanel;
    PanelTerritory: TPanel;
    PanelCongregation: TPanel;
    Panel2: TPanel;
    PanelCongregationTitle: TPanel;
    PanelCongregationToolbar: TPanel;
    PanelTerritoryToolbar: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    TabSheetUsers: TTabSheet;
    TabSheetTerritory: TTabSheet;
    TabSheetCongregation: TTabSheet;
    ValueListEditorCongregation: TValueListEditor;
    ValueListEditorCongregation1: TValueListEditor;
    ValueListEditorTerritory: TValueListEditor;
    procedure btnAddCongregationClick(Sender: TObject);
    procedure btnAddTerritoryClick(Sender: TObject);
    procedure btnDeleteCongregationClick(Sender: TObject);
    procedure btnDeleteTerritoryClick(Sender: TObject);
    procedure btnRefreshCongregationsClick(Sender: TObject);
    procedure btnRefreshTerritoriesClick(Sender: TObject);
    procedure btnSaveCongregationClick(Sender: TObject);
    procedure btnSaveTerritoryClick(Sender: TObject);
    procedure ListViewCongregationsEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure ListViewCongregationsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewTerritoriesSelectItem(Sender: TObject; Item: TListItem;
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


procedure TFormSettings.btnRefreshTerritoriesClick(Sender: TObject);
var
  i: Integer;
  li: TListItem;
begin
  dataModuleMain.territories.refresh;
  ListViewTerritories.Items.Clear;
  for i:=0 to Length(DataModuleMain.territories.Items) - 1 do
  begin
    li:=ListViewTerritories.Items.Add;
    li.Caption:=DataModuleMain.territories.Items[i].id;
    li.SubItems.add(DataModuleMain.territories.Items[i].name);
    li.SubItems.add(DataModuleMain.territories.Items[i].description);
  end;
end;

procedure TFormSettings.btnSaveCongregationClick(Sender: TObject);
begin
  DataModuleMain.congregations.update(
     ListViewCongregations.Selected.caption,
     ValueListEditorCongregation.Strings);
  btnRefreshCongregations.Click;
end;

procedure TFormSettings.btnSaveTerritoryClick(Sender: TObject);
begin
  DataModuleMain.territories.update(
     ListViewTerritories.Selected.caption,
     ValueListEditorTerritory.Strings);
  btnRefreshTerritories.Click;
end;

procedure TFormSettings.ListViewCongregationsEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit:=False;
end;

procedure TFormSettings.btnDeleteCongregationClick(Sender: TObject);
begin
  DataModuleMain.congregations.delete(ListViewCongregations.Selected.caption);
  btnRefreshCongregations.Click;
end;

procedure TFormSettings.btnDeleteTerritoryClick(Sender: TObject);
begin
  DataModuleMain.territories.delete(ListViewTerritories.Selected.caption);
  btnRefreshTerritories.Click;
end;

procedure TFormSettings.btnAddCongregationClick(Sender: TObject);
var
  initial: TStringList;
begin
  initial:=TStringList.Create;
  initial.Values['name']:='New Congregation';
  DataModuleMain.congregations.Add(initial);
  initial.free;
  btnRefreshCongregations.click;

end;

procedure TFormSettings.btnAddTerritoryClick(Sender: TObject);
var
  initial: TStringList;
begin
  initial:=TStringList.Create;
  initial.Values['name']:='Territory';
  try
     DataModuleMain.territories.Add(initial);
  finally
      initial.free;
      btnRefreshTerritories.click;
  end;
end;


procedure TFormSettings.ListViewCongregationsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  i: integer;
begin
  ValueListEditorCongregation.Clear;
  if Selected then
  begin
    PanelCongregationTitle.Caption:='Congregation ID ' + Item.Caption;
    PanelCongregationToolbar.Tag:=Item.Index;
    for i:=0 to Item.SubItems.Count - 1 do
    begin
      ValueListEditorCongregation.InsertRow(
          ListViewCongregations.Columns[i+1].Caption,
          Item.SubItems[i],
          true);
    end;
  end
  else
  begin
    PanelCongregationToolbar.Tag := -1;
    PanelCongregationTitle.Caption:='No Congregation Selected'
  end;

  btnDeleteCongregation.enabled:=Selected;
  PanelCongregation.Enabled:=Selected;
end;

procedure TFormSettings.ListViewTerritoriesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  i: integer;
begin
  ValueListEditorTerritory.Clear;
  if Selected then
  begin
    PanelTerritoryTitle.Caption:='Territory ID ' + Item.Caption;

    for i:=0 to Item.SubItems.Count - 1 do
    begin
      ValueListEditorTerritory.InsertRow(
          ListViewTerritories.Columns[i+1].Caption,
          Item.SubItems[i],
          true);
    end;
  end
  else
  begin
    PanelTerritoryTitle.Caption:='No Territory Selected'
  end;

  btnDeleteTerritory.enabled:=Selected;
  PanelTerritory.Enabled:=Selected;
end;


end.

