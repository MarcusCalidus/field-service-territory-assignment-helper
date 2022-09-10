unit unitData;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, SQLite3Conn, db, contnrs;

type

  generic TDataObject<T> = class
    Items: array of T;
    constructor Create;
    procedure ClearItems();
    procedure Add(Value: T);
    procedure Refresh();
  end;

  TCongregation = class(TObject)  
        constructor Create(fields: TFields); overload;
  public
    tableName: string; static;
        id: string;
        name: string;
  end;

  { TDataModuleMain }

  TDataModuleMain = class(TDataModule)
    DBConnection: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    congregations: specialize TDataObject<TCongregation>;
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

{ TDataModuleMain }

procedure TDataModuleMain.DataModuleCreate(Sender: TObject);
begin
  self.congregations:=specialize TDataObject<TCongregation>.Create;
end;

{ TDataObject }

constructor TDataObject.Create;
begin
  Items := [];
end;

procedure TDataObject.Add(Value: T);
begin
  SetLength(Items, Length(Items) + 1);
  Items[Length(Items) - 1] := Value;
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
var
  query: TSQLQuery;
  trans: TSQLTransaction;
begin
  self.ClearItems();
  query:=TSQLQuery.Create(DataModuleMain);
  trans:=TSQLTransaction.Create(DataModuleMain);
  trans.DataBase:=DataModuleMain.DBConnection;
  query.Transaction:=trans;
  try
    query.sql.text:='select * from ' + T.tableName;
    trans.StartTransaction;
    query.open;
    while not query.EOF do
    begin
      SetLength(Items, Length(Items) + 1);
      Items[Length(Items) - 1] := T.Create(query.Fields);
      query.next;
    end;
    query.close;
    trans.commit;
  finally
    query.Free;
    trans.Free;
  end;
end;

begin
     TCongregation.tableName:='congregations';
end.

