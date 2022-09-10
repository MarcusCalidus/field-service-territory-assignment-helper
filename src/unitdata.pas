unit unitData;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, SQLite3Conn, db, contnrs, md5, Dialogs;

type

  generic TDataObject<T> = class
    Items: array of T;
    Query: TSQLQuery;
    Transaction: TSQLTransaction;
    constructor Create;
    destructor Destroy;
    procedure ClearItems();
    procedure Add(initialValues: TStrings; refreshData: boolean = false);
    procedure Delete(ID: string; refreshData: boolean = false);
    procedure Update(ID: string; newValues: TStrings; refreshData: boolean = false);
    function FindById(ID: string): T;
    function FindByName(Name: string): T;
    procedure Refresh();
    procedure asStrings(Strings: TStrings; addObjects: boolean = false);
  end;

  TCongregation = class(TObject)
        constructor Create(fields: TFields); overload;
  public
    tableName: string; static;
    id: string;
    name: string;
  end;

    TTerritory = class(TObject)
      constructor Create(fields: TFields); overload;
    public
      tableName: string; static;
      id: string;
      name: string;
      description: string;
    end;

    TPublisher = class(TObject)
      constructor Create(fields: TFields); overload;
    public
      tableName: string; static;
      id: string;
      name: string;
      congregation_id: string;
    end;

  TUser = class(TObject)
    constructor Create(fields: TFields); overload;
  public
    tableName: string; static;
    id: string;
    name: string;
    is_admin: integer;
    congregation_id: string;
    pw_hash: string;
    function checkPassword(pw_to_check: string): boolean;
  end;

  { TDataModuleMain }

  TDataModuleMain = class(TDataModule)
    DBConnection: TSQLite3Connection;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    congregations: specialize TDataObject<TCongregation>;
    territories: specialize TDataObject<TTerritory>;
    publishers: specialize TDataObject<TPublisher>;
    users: specialize TDataObject<TUser>;

    currentUser: string;
    currentUser_is_admin: integer;
  end;

var
  DataModuleMain: TDataModuleMain;

implementation

{$R *.lfm}

{ TCongregation }

constructor TCongregation.Create(fields: TFields);
begin
  inherited Create;
  self.id:=fields.FieldByName('id').AsString;
  self.name:=fields.FieldByName('name').asString;
end;

{ TUser }

constructor TUser.Create(fields: TFields);
begin
  inherited Create;
  self.id:=fields.FieldByName('id').AsString;
  self.name:=fields.FieldByName('name').asString;
  self.is_admin:=fields.FieldByName('is_admin').AsInteger;
  self.congregation_id:=fields.FieldByName('congregation_id').asString;
  self.pw_hash:=fields.FieldByName('pw_hash').asString;
end;

function TUser.checkPassword(pw_to_check: string): boolean;
var
  d: string;
begin
  result:=pw_hash = MD5Print(MD5String(pw_to_check));
end;

{ TTerritory }

constructor TTerritory.Create(fields: TFields);
begin
  inherited Create;
  self.id:=fields.FieldByName('id').AsString;
  self.name:=fields.FieldByName('name').asString;
  self.description:=fields.FieldByName('description').asString;
end;

{ TPublisher }

constructor TPublisher.Create(fields: TFields);
begin
  inherited Create;
  self.id:=fields.FieldByName('id').AsString;
  self.name:=fields.FieldByName('name').asString;
  self.congregation_id:=fields.FieldByName('congregation_id').asString;
end;

{ TDataModuleMain }

procedure TDataModuleMain.DataModuleCreate(Sender: TObject);
begin
  self.congregations:=specialize TDataObject<TCongregation>.Create;
  self.territories:=specialize TDataObject<TTerritory>.Create;
  self.publishers:=specialize TDataObject<TPublisher>.Create;
  self.users:=specialize TDataObject<TUser>.Create;
end;

{ TDataObject }

constructor TDataObject.Create;
begin
  Items := [];
  Query:=TSQLQuery.Create(DataModuleMain);
  Transaction:=TSQLTransaction.Create(DataModuleMain);
  Transaction.DataBase:=DataModuleMain.DBConnection; 
  Query.Transaction:=Transaction;
end;

destructor TDataObject.Destroy;
begin
  Query.Free;
  Transaction.Free;
end;

function TDataObject.FindById(ID: string): T;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to Length(Items)-1 do
  begin
    if Items[i].id = ID then
    begin
       result:=Items[i];
       break;
    end;
  end;
end;

function TDataObject.FindByName(Name: string): T;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to Length(Items)-1 do
  begin
    if Items[i].Name = Name then
    begin
       result:=Items[i];
       break;
    end;
  end;
end;

procedure TDataObject.Add(initialValues: TStrings; refreshData: boolean = false);
var
  i: integer;
  names: String;
  values: String;
  uuid: TGuid;
begin
  CreateGUID(uuid);
  if initialValues.IndexOfName('ID')<0 then
     initialValues.Values['ID']:=GUIDToString(uuid);
  for i:=0 to initialValues.Count-1 do
  begin
    names := names + initialValues.Names[i];
    values := values + ':'+ initialValues.Names[i];
    if (i < initialValues.Count-1) then
    begin
       names := names +', ';
       values := values +', ';
    end;
  end;
  Query.SQL.Text:='insert into ' + T.tableName + ' (' + names + ') values (' + values + ');';
  Transaction.StartTransaction;
  Query.Prepare;
  for i:=0 to initialValues.count - 1 do
  begin
    Query.ParamByName(initialValues.Names[i]).AsString:=initialValues.ValueFromIndex[i];
  end;
  try
    Query.ExecSQL;
    Transaction.Commit;
  except
    Transaction.Rollback
  end;
  if refreshData then
    self.Refresh();
end;

procedure TDataObject.Delete(ID: String; refreshData: Boolean);
begin
  Query.SQL.Text:='delete from ' + T.tableName + ' where ID=''' + ID + '''';
  Transaction.StartTransaction;
  try
    Query.ExecSQL;
    Transaction.Commit;
  except
    Transaction.Rollback
  end;
  if refreshData then
    self.Refresh();
end;

procedure TDataObject.Update(ID: String; newValues: TStrings; refreshData: boolean = false);
var
  i: integer;
  setStr: String;
begin
  for i:=0 to newValues.Count-1 do
  begin
    setStr := setStr + newValues.Names[i] + '=' + ':'+ newValues.Names[i];
    if (i < newValues.Count-1) then
    begin
       setStr := setStr +', ';
    end;
  end;
  Query.SQL.Text:='update ' + T.tableName + ' set ' + setStr + ' where id=''' + ID + ''';';
  Transaction.StartTransaction;
  Query.Prepare;
  for i:=0 to newValues.count - 1 do
  begin
    Query.ParamByName(newValues.Names[i]).AsString:=newValues.ValueFromIndex[i];
  end;
  try
    Query.ExecSQL;
    Transaction.Commit;
  except
    Transaction.Rollback
  end;
  if refreshData then
    self.Refresh();
end;

procedure TDataObject.ClearItems();
var
  i: Integer;
begin
  for i:=0 to Length(Items) - 1 do
  begin
    Items[i].Free;
  end;
  Items:=[];
end;

procedure TDataObject.asStrings(Strings: TStrings; addObjects: boolean = false);
var
  i: integer;
begin
  for i:=0 to Length(Items) - 1 do
  begin
    if addObjects then
      Strings.AddObject(Items[i].name, Items[i])
    else
      Strings.Add(Items[i].name);
  end;
end;

procedure TDataObject.Refresh();
begin
  self.ClearItems();
  Transaction.StartTransaction;
  try
    query.sql.text:='select * from ' + T.tableName;

    query.open;
    while not query.EOF do
    begin
      SetLength(Items, Length(Items) + 1);
      Items[Length(Items) - 1] := T.Create(query.Fields);
      query.next;
    end;
    query.close;
    Transaction.commit;
  except
    Transaction.rollback;
  end;
end;

begin
  TCongregation.tableName:='congregations';
  TTerritory.tableName:='territories';
  TPublisher.tableName:='publishers';
  TUser.tableName:='users';
end.

