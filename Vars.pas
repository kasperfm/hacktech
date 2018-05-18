unit Vars;

interface

uses inifiles;

var
  MissionFile: TINIFile;
  MissionFilename: string;
  LevelsCompleted: TINIFile;
  LevelsCompletedFilename: string;
  ServerFile: TINIFile;
  ServerFilename: string;

  MenuItem: string;
  MenuRunning: boolean;
  Finished: boolean = false;
  max: integer;
  Temp1: string;
  Temp2: string;
  TypedCommand: string;
  CurrentServer: string;
  CurrentUser: string;
  RecentlyDownloaded: string;
  RecentlyUploaded: string;
  RecentlyExeced: string;
  RecentlyShutdown: string;
  RecentlyCurrentServer: string;
  MissionsCompleted: array[0..20] of boolean;
  Mission: string;
  Objective: string;
  ObjectiveMsg: string;
  EndMsg: string;

  IP: array of string;
  Hostname: array of string;
  Status: array [1..255] of boolean;

  // Server variables
  Connected: boolean;
  CorrectPort: boolean;
  SSHLoggedIn: boolean;
  AdminLoggedIn: boolean;
  CurrentPort: integer;
  OpenPorts: array [1..10] of integer;
  ListProtectedServer: boolean;
  Username: string;
  Password: string;
  AdminPass: string;
  UploadAble: boolean;
  DeleteAble: boolean;
  PassCrackAble: boolean;
  
  EnteredUsername: string;
  EnteredPassword: string;
  Counter: integer;
implementation

end.
