unit unitLogin;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  unitData;

type

  { TFormLogin }

  TFormLogin = class(TForm)
    BtnLogin: TBitBtn;
    EditUser: TEdit;
    EditPassword: TEdit;
    procedure BtnLoginClick(Sender: TObject);
  private

  public

  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.lfm}

{ TFormLogin }

procedure TFormLogin.BtnLoginClick(Sender: TObject);
var
  user: TUser;
begin
  DataModuleMain.users.Refresh();
  user:=DataModuleMain.users.FindById(EditUser.Text);
  if not assigned(user) then
    raise Exception.Create('User not found');
  if not user.checkPassword(EditPassword.Text) then
    raise Exception.Create('Password invalid for user');

  DataModuleMain.currentUser:=user.id;
  DataModuleMain.currentUser_is_admin:=user.is_admin;
  self.ModalResult:=mrOk;
end;

end.

