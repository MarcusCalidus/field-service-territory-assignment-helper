unit unitData;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, SQLite3Conn, db, contnrs;

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
    procedure Refresh();
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

  { TDataModuleMain }

  TDataModuleMain = class(TDataModule)
    DBConnection: TSQLite3Connection;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    congregations: specialize TDataObject<TCongregation>;
    territories: specialize TDataObject<TTerritory>;
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

{ TTerritory }

constructor TTerritory.Create(fields: TFields);
begin
  inherited Create;
  self.id:=fields.FieldByName('id').AsString;
  self.name:=fields.FieldByName('name').asString;
  self.description:=fields.FieldByName('description').asString;
end;

{ TDataModuleMain }

procedure TDataModuleMain.DataModuleCreate(Sender: TObject);
begin
  self.congregations:=specialize TDataObject<TCongregation>.Create;
  self.territories:=specialize TDataObject<TTerritory>.Create;
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

procedure TDataObject.Add(initialValues: TStrings; refreshData: boolean = false);
var
  i: integer;
  names: String;
  values: String;
  uuid: TGuid;
begin
  CreateGUID(uuid);
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
end.

