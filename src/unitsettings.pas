unit unitSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, md5,
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
    btnSaveUser: TBitBtn;
    btnSaveTerritory: TBitBtn;
    CheckBoxUpdateUserPW: TCheckBox;
    CheckBoxUserIsAdmin: TCheckBox;
    ComboBoxUserCongregation: TComboBox;
    EditUserPassword: TEdit;
    EditUserId: TEdit;
    EditUserName: TEdit;
    ImageList1: TImageList;
    ListViewCongregations: TListView;
    Panel4: TPanel;
    PanelUser: TPanel;
    ListViewUsers: TListView;
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
    Splitter3: TSplitter;
    TabSheetUsers: TTabSheet;
    TabSheetTerritory: TTabSheet;
    TabSheetCongregation: TTabSheet;
    ValueListEditorCongregation: TValueListEditor;
    ValueListEditorTerritory: TValueListEditor;
    procedure btnAddCongregationClick(Sender: TObject);
    procedure btnAddTerritoryClick(Sender: TObject);
    procedure btnAddUserClick(Sender: TObject);
    procedure btnDeleteCongregationClick(Sender: TObject);
    procedure btnDeleteTerritoryClick(Sender: TObject);
    procedure btnDeleteUserClick(Sender: TObject);
    procedure btnRefreshCongregationsClick(Sender: TObject);
    procedure btnRefreshTerritoriesClick(Sender: TObject);
    procedure btnRefreshUsersClick(Sender: TObject);
    procedure btnSaveCongregationClick(Sender: TObject);
    procedure btnSaveTerritoryClick(Sender: TObject);
    procedure btnSaveUserClick(Sender: TObject);
    procedure CheckBoxUpdateUserPWChange(Sender: TObject);
    procedure ListViewCongregationsEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure ListViewCongregationsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewTerritoriesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewUsersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ValueListEditorCongregation1GetPickList(Sender: TObject;
      const KeyName: string; Values: TStrings);
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

procedure TFormSettings.btnRefreshUsersClick(Sender: TObject);
var
  i: Integer;
  li: TListItem;
  cong: TCongregation;
begin
  dataModuleMain.users.refresh;
  dataModuleMain.congregations.refresh;
  ListViewUsers.Items.Clear;
  for i:=0 to Length(DataModuleMain.users.Items) - 1 do
  begin
    li:=ListViewUsers.Items.Add;
    li.Caption:=DataModuleMain.users.Items[i].id;
    li.SubItems.add(DataModuleMain.users.Items[i].name);
    li.SubItems.add(IntToStr(DataModuleMain.users.Items[i].is_admin));
    cong:=DataModuleMain.congregations.FindById(DataModuleMain.users.Items[i].congregation_id);
    li.SubItems.add(cong.name);
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

procedure TFormSettings.btnSaveUserClick(Sender: TObject);
var
  newValues: TStrings;
begin
  newValues:=TStringList.Create;
  DataModuleMain.congregations.Refresh();
  try
     newValues.Values['name']:=EditUserName.text;
     newValues.Values['is_admin']:=BoolToStr(CheckBoxUserIsAdmin.checked, '1', '0');
     newValues.Values['congregation_id']:=DataModuleMain.congregations.FindByName(ComboBoxUserCongregation.Text).id;
     if CheckBoxUpdateUserPW.checked then
        newValues.Values['pw_hash']:=MD5Print(MD5String(EditUserPassword.Text));
     DataModuleMain.users.update(
       EditUserId.text,
       newValues);
     btnRefreshUsers.Click;
  finally
      newValues.Free;
  end;
end;

procedure TFormSettings.CheckBoxUpdateUserPWChange(Sender: TObject);
begin
  EditUserPassword.enabled:=CheckBoxUpdateUserPW.checked;
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

procedure TFormSettings.btnDeleteUserClick(Sender: TObject);
begin
  if ListViewUsers.Selected.caption = DataModuleMain.currentUser then
    raise Exception.Create('You cannot delete the active user!');
  DataModuleMain.users.delete(ListViewUsers.Selected.caption);
  btnRefreshUsers.Click;
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

procedure TFormSettings.btnAddUserClick(Sender: TObject);
var
  initial: TStringList;
  newUser: string;
begin
  newUser:=InputBox('Username', 'Enter the login name of the user:', 'new_user');
  if (newUser <> 'new_user') then
  begin
    DataModuleMain.congregations.Refresh();
    initial:=TStringList.Create;
    initial.Values['ID']:=newUser;
    initial.Values['name']:='Territory';
    initial.Values['is_admin']:='1';
    initial.Values['congregation_id']:=DataModuleMain.congregations.items[0].id;
    try
       DataModuleMain.users.Add(initial);
    finally
        initial.free;
        btnRefreshUsers.click;
    end;
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

procedure TFormSettings.ListViewUsersSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  i: integer;
begin
  EditUserId.Text:='';
  EditUserName.Text:='';
  EditUserPassword.Text:='';
  CheckBoxUpdateUserPW.checked:=false;
  CheckBoxUserIsAdmin.Checked:=false;
  ComboBoxUserCongregation.ItemIndex:=-1;
  ComboBoxUserCongregation.items.clear;
  if Selected then
  begin
    EditUserId.Text:=Item.Caption;
    EditUserName.Text:=Item.SubItems[0];
    CheckBoxUserIsAdmin.Checked:=StrToBool(Item.SubItems[1]);
    DataModuleMain.congregations.Refresh();
    DataModuleMain.congregations.asStrings(ComboBoxUserCongregation.items);
    for i:=0 to ComboBoxUserCongregation.items.Count - 1 do
    begin
      if ComboBoxUserCongregation.items[i]=Item.SubItems[2] then
      begin
        ComboBoxUserCongregation.ItemIndex:=i;
      end;
    end;
  end;

  btnDeleteUser.enabled:=Selected;
  PanelUser.Enabled:=Selected;
end;

procedure TFormSettings.ValueListEditorCongregation1GetPickList(
  Sender: TObject; const KeyName: string; Values: TStrings);
begin

end;


end.

