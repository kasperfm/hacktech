unit ScriptFunctions;

interface

uses sysutils;

function ReadString: string;
procedure Wait(timer: integer);
function GetDeleteAble: string;
function GetCurrentServer: string;
function GetUsername: string;
function GetPassword: string;
function GetCurrentUser: string;
function GetConnected: boolean;
function GetCurrentPort: integer;
function GetAdminLoggedIn: boolean;
function LastCommand: string;
procedure SetConnected;
procedure SetCorrectPort;
procedure SetSSHLoggedIn;
procedure SetCurrentUser(user: string);
procedure SetAdminLoggedIn;
function GetAdminPass: string;

implementation

uses Vars;

function readString: string;
begin
  Readln(result);
end;

procedure Wait(timer: integer);
begin
  Sleep(timer);
end;

function GetDeleteAble: string;
var
  tempVar: string;
begin
  tempVar:=BoolToSTr(DeleteAble);
  if tempVar='0' then
    Result:='false'
  else
    Result:='true';
end;

function GetUsername: string;
begin
  Result:=Username;
end;

function GetPassword: string;
begin
  Result:=Password;
end;

function GetCurrentServer: string;
begin
  Result:=CurrentServer;
end;

function GetCurrentUser: string;
begin
  Result:=CurrentUser;
end;

function GetConnected: boolean;
begin
  Result:=Connected;
end;

function GetCurrentPort: integer;
begin
  Result:=CurrentPort;
end;

function LastCommand: string;
begin
  Result:=TypedCommand;
end;

procedure SetConnected;
begin
  Connected:=True;
end;

procedure SetCorrectPort;
begin
  CorrectPort:=True;
end;

procedure SetSSHLoggedIn;
begin
  SSHLoggedIn:=True;
end;

procedure SetCurrentUser(user: string);
begin
  CurrentUser:=User;
end;

function GetAdminLoggedIn: boolean;
begin
  Result:=AdminLoggedIn;
end;

procedure SetAdminLoggedIn;
begin
  AdminLoggedIn:=True;
end;

function GetAdminPass: string;
begin
  Result:=AdminPass;
end;

end.
