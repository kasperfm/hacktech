{
  Name: HackTech
  Version: 0.2.0
  Sub-Version: Alpha-02
  Author: KasperFM - https://kasperfm.com
}

program HackTech;

{$APPTYPE CONSOLE}

uses
  Console in 'Console.pas',
  uPSCompiler,
  uPSRuntime,
  uPSC_std,
  uPSR_std,
  uPSC_controls,
  uPSR_controls,
  Windows,
  SysUtils,
  INIFiles,
  Classes,
  ScriptFunctions in 'ScriptFunctions.pas',
  Vars in 'Vars.pas';

var
  Running: boolean;
  i: integer;
  j: integer;
  p: integer;
  temp: TStringList;
  
const
  ProductName: string = 'HackTech';
  Version: string = '0.2.0 Alpha-02';
  MadeBy: string = 'KasperFM';
  Debug: boolean = false;


procedure Print(const Text: string; Color: Byte);
var
  OldColor: Byte;
begin
  OldColor := TextColor;
  TextColor(Color);
  Writeln(Text);
  TextColor(OldColor);
end;

procedure Print2(const Text: string; Color: Byte);
var
  OldColor: Byte;
begin
  OldColor := TextColor;
  TextColor(Color);
  Write(Text);
  TextColor(OldColor);
end;

procedure Encrypt(filename: string);
var
  Key: integer;
  filetoopen, filetowriteto : string;
  file1, file2 : tfilestream;
  buff, readbuff : char;
  dummy1 : integer;
begin
  Key:=410965;

  if FileExists(filename) then
    begin
      filetoopen:=filename;
      filetowriteto:=filename+'_enc';
      file1:=tfilestream.Create(filetoopen,fmopenread);
      file2:=tfilestream.Create(filetowriteto,fmopenwrite or fmcreate or fmsharedenywrite);

      for dummy1:=0 to file1.Size -1 do
        begin
          file1.Read(buff,sizeof(buff));
          readbuff:=char(pchar(buff)+ Key);
          file2.Write(readbuff,sizeof(readbuff));
        end;

      file1.Free;
      file2.Free;

      DeleteFile(filetoopen);
      CopyFile(PChar(filetowriteto), PChar(filetoopen), false);
      DeleteFile(filetowriteto);
    end;
end;

procedure Decrypt(filename: string);
var
  Key: integer;
  filetoopen, filetowriteto : string;
  file1, file2 : tfilestream;
  buff, readbuff : char;
  dummy1 : integer;
begin
  Key:=410965;

  if FileExists(filename) then
    begin
      filetoopen:=filename;
      filetowriteto:=filename+'_dec';
      file1:=tfilestream.Create(filetoopen,fmopenread);
      file2:=tfilestream.Create(filetowriteto,fmopenwrite or fmcreate or fmsharedenywrite);

      for dummy1:=0 to file1.Size -1 do
        begin
          file1.Read(buff,sizeof(buff));
          readbuff:=char(pchar(buff)- Key);
          file2.Write(readbuff,sizeof(readbuff));
        end;

      file1.Free;
      file2.Free;

      DeleteFile(filetoopen);
      CopyFile(PChar(filetowriteto), PChar(filetoopen), false);
      DeleteFile(filetowriteto);
    end;
end;

procedure Pause;
begin
  Print('Press any key...', Yellow);
  ReadKey;
  Write(#13);
  ClrEol;
end;

procedure Disconnect;
begin
  Connected:=False;
  SSHLoggedIn:=False;
  AdminLoggedIn:=False;
  CurrentPort:=0;
  CurrentUser:='root';
  Username:='root';
  Password:='root';
  DeleteAble:=True;
  UploadAble:=True;
  CurrentServer:='127.0.0.1';
end;

procedure ShutdownServer(serverip: string);
begin
  for i:=1 to Length(IP) do
    if IP[i]=serverip then
      begin
        Disconnect;
        Status[i]:=False;
      end;
end;

procedure FileList(const PathName, FileMask : string);
var
  Rec  : TSearchRec;
  Path : string;
begin
  Path := IncludeTrailingBackslash(PathName);
    if FindFirst (Path + FileMask, faAnyFile - faDirectory, Rec) = 0
        then try
        repeat
          begin
            Print('- '+ExtractFilename(Path + Rec.Name), White); // char #9 er tab
          end;
        until FindNext(Rec) <> 0;
      finally
        FindClose(Rec);
    end;
end;

procedure CleanUp;
begin
  LevelsCompleted.Free;
  NormVideo;
  ClrScr;
end;

function Split(Input: string; Deliminator: string; Index: integer): string;
var
  StringLoop, StringCount: integer;
  Buffer: string;
begin
  StringCount := 0;
  for StringLoop := 1 to Length(Input) do
    begin
      if (Copy(Input, StringLoop, 1) = Deliminator) then
        begin
          Inc(StringCount);
          if StringCount = Index then
            begin
              Result := Buffer;
              Exit;
            end
        else
          begin
            Buffer := '';
          end;
      end
    else
      begin
        Buffer := Buffer + Copy(Input, StringLoop, 1);
      end;
    end;
  Result := Buffer;
end;

procedure LoadIPs(filename: string);
var
  i, z: Integer;
  f: TextFile;
  t: string;
begin
  AssignFile(f, fileName);
  Reset(f);
  z := 0;
  SetLength(IP, 0);

  repeat
    Inc(z);
    readln(f, t);
    SetLength(IP, Length(IP) + Length(t));
    IP[z] := t;
  until EOF(f);

  SetLength(IP, Length(IP) + 3 * z);
  for i := 1 to z do IP[i] := Split(IP[i], ':', 1);
  SetLength(IP, Length(IP) + 2);
  CloseFile(f);
end;

procedure LoadHostnames(filename: string);
var
  i, z: Integer;
  f: TextFile;
  t: string;
begin
  AssignFile(f, fileName);
  Reset(f);
  z := 0;
  SetLength(Hostname, 0);

  repeat
    Inc(z);
    readln(f, t);
    SetLength(Hostname, Length(Hostname) + Length(t));
    Hostname[z] := t;
  until EOF(f);

  SetLength(Hostname, Length(Hostname) + 3 * z);
  for i := 1 to z do Hostname[i] :=Split(Hostname[i], ':', 2);
  SetLength(Hostname, Length(Hostname) + 2);
  CloseFile(f);
end;

procedure PrintWelcome;
begin
  Print('Welcome to '+ProductName, Yellow);
  Print('Version: '+Version, Yellow);
  Print('___________________________________________________________', Yellow);
  WriteLn('');
end;

procedure LoadMission(MissionID: string);
begin
  Mission:=MissionID;

  MissionFilename:=IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\missions\'+MissionID+'.ht_m';
  MissionFile:=TINIFile.Create(MissionFilename);
  Disconnect;

  Objective:=MissionFile.ReadString('Data', 'Objective', '');
  ObjectiveMsg:=MissionFile.ReadString('Data', 'ObjectiveMsg', '');
  EndMsg:=MissionFile.ReadString('Data', 'EndMsg', '');

  Print(MissionFile.ReadString('Data', 'MissionName', ''), White);
  Print('', white);
  Print('Mission objective: '+ObjectiveMsg, White);

  MissionFile.Free;
end;

function MissionObjective: boolean;
var
  i: integer;
begin
  if Split(Objective, ' ', 1) = 'download' then
    begin
      if (Split(Objective, ' ', 2) = RecentlyDownloaded) and
         (Split(Objective, ' ', 3) = 'from') and
         (Split(Objective, ' ', 4) = CurrentServer)
       then
        begin
          Randomize;
          RecentlyDownloaded:=IntToStr(Random(100));
          Result:=True;
        end;
    end;

  if Split(Objective, ' ', 1) = 'upload' then
    begin
      if (Split(Objective, ' ', 2) = RecentlyUploaded) and
         (Split(Objective, ' ', 3) = 'to') and
         (Split(Objective, ' ', 4) = CurrentServer)
      then
        begin
          Randomize;
          RecentlyUploaded:=IntToStr(Random(100));
          Result:=True;
        end;
    end;

  if Split(Objective, ' ', 1) = 'takedown' then
    begin
      if Split(Objective, ' ', 2) = CurrentServer then
        begin
          for i:=1 to Length(IP) do
            if IP[i]=CurrentServer then
              if Status[i]=False then
                Result:=True;
        end;
    end;

  if Split(Objective, ' ', 1) = 'exec' then
    begin
      if (Split(Objective, ' ', 2) = RecentlyExeced) and
         (Split(Objective, ' ', 3) = 'at') and
         (Split(Objective, ' ', 4) = RecentlyCurrentServer)
      then
        begin
          Randomize;
          RecentlyCurrentServer:=IntToStr(Random(100));
          Randomize;
          RecentlyExeced:=IntToStr(Random(100));
          Result:=True;
        end;
    end;

  if Result=True then
    begin
      Print(EndMsg, White);
      Print('', White);
      Print('___________________________________________________________', White);
      Print('', White);
      LevelsCompleted.WriteBool('Completed', 'M'+IntToStr(StrToInt(Copy(Mission, 2, 3))+1), true);
      LoadMission('m'+IntToStr(StrToInt(Copy(Mission, 2, 3))+1));
    end;

  Result:=False;
end;

function RandomString(PWLen: integer; PWChars: string): string;
var
  N, K, X, Y: integer;
begin
  Randomize;
  if (PWlen > Length(PWChars)) then K := Length(PWChars)-1
    else K := PWLen;
  SetLength(result, K);
  Y := Length(PWChars);
  N := 0;

  while N < K do begin
    X := Random(Y) + 1;
    if (pos(PWChars[X], result) = 0) then begin
      inc(N);
      Result[N] := PWChars[X];
    end;
  end;
end;

function ScriptOnUses(Sender: TPSPascalCompiler; const Name: AnsiString): Boolean;
begin
  if Name = 'SYSTEM' then
    begin
      Sender.AddDelphiFunction('procedure Print(const Text: string; Color: Byte)');
      Sender.AddDelphiFunction('procedure Print2(const Text: string; Color: Byte)');
      Sender.AddDelphiFunction('function ReadString: string');
      Sender.AddDelphiFunction('procedure Wait(timer: integer)');
      Sender.AddDelphiFunction('function GetDeleteAble: string');
      Sender.AddDelphiFunction('function GetUsername: string');
      Sender.AddDelphiFunction('function GetPassword: string');
      Sender.AddDelphiFunction('function GetCurrentServer: string');
      Sender.AddDelphiFunction('function GetCurrentUser: string');
      Sender.AddDelphiFunction('function GetConnected: boolean');
      Sender.AddDelphiFunction('function GetCurrentPort: integer');
      Sender.AddDelphiFunction('function Split(Input: string; Deliminator: string; Index: integer): string');
      Sender.AddDelphiFunction('function LastCommand: string');
      Sender.AddDelphiFunction('procedure SetConnected');
      Sender.AddDelphiFunction('procedure SetCorrectPort');
      Sender.AddDelphiFunction('procedure SetSSHLoggedIn');
      Sender.AddDelphiFunction('procedure Disconnect');
      Sender.AddDelphiFunction('procedure SetCurrentUser(user: string)');
      Sender.AddDelphiFunction('procedure ShutdownServer(serverip: string)');
      Sender.AddDelphiFunction('function GetAdminLoggedIn: boolean');
      Sender.AddDelphiFunction('procedure SetAdminLoggedIn');
      Sender.AddDelphiFunction('function GetAdminPass: string');

      Result := True;
    end
  else
    Result := False;
end;

procedure ExecuteScript(const ScriptFile: string);
var
  Compiler: TPSPascalCompiler;
  Exec: TPSExec;
  Data: AnsiString;
begin
  Compiler := TPSPascalCompiler.Create;
  Compiler.OnUses := ScriptOnUses;
  Temp.Clear;
  Temp.LoadFromFile(ScriptFile);

  if not Compiler.Compile(Temp.Text) then
    begin
      Print('Script error !', LightRed);
      Compiler.Free;
      Exit;
    end;

  Compiler.GetOutput(Data);
  Compiler.Free;

  Exec := TPSExec.Create;

  Exec.RegisterDelphiFunction(@Print, 'PRINT', cdRegister);
  Exec.RegisterDelphiFunction(@Print2, 'PRINT2', cdRegister);
  Exec.RegisterDelphiFunction(@readString, 'READSTRING', cdRegister);
  Exec.RegisterDelphiFunction(@Wait, 'WAIT', cdRegister);
  Exec.RegisterDelphiFunction(@GetDeleteAble, 'GETDELETEABLE', cdRegister);
  Exec.RegisterDelphiFunction(@GetUsername, 'GETUSERNAME', cdRegister);
  Exec.RegisterDelphiFunction(@GetPassword, 'GETPASSWORD', cdRegister);
  Exec.RegisterDelphiFunction(@GetCurrentServer, 'GETCURRENTSERVER', cdRegister);
  Exec.RegisterDelphiFunction(@GetCurrentUser, 'GETCURRENTUSER', cdRegister);
  Exec.RegisterDelphiFunction(@GetConnected, 'GETCONNECTED', cdRegister);
  Exec.RegisterDelphiFunction(@GetCurrentPort, 'GETCURRENTPORT', cdRegister);
  Exec.RegisterDelphiFunction(@Split, 'SPLIT', cdRegister);
  Exec.RegisterDelphiFunction(@LastCommand, 'LASTCOMMAND', cdRegister);
  Exec.RegisterDelphiFunction(@SetConnected, 'SETCONNECTED', cdRegister);
  Exec.RegisterDelphiFunction(@SetCorrectPort, 'SETCORRECTPORT', cdRegister);
  Exec.RegisterDelphiFunction(@SetSSHLoggedIn, 'SETSSHLOGGEDIN', cdRegister);
  Exec.RegisterDelphiFunction(@Disconnect, 'DISCONNECT', cdRegister);
  Exec.RegisterDelphiFunction(@SetCurrentUser, 'SETCURRENTUSER', cdRegister);
  Exec.RegisterDelphiFunction(@ShutdownServer, 'SHUTDOWNSERVER', cdRegister);
  Exec.RegisterDelphiFunction(@GetAdminLoggedIn, 'GETADMINLOGGEDIN', cdRegister);
  Exec.RegisterDelphiFunction(@SetAdminLoggedIn, 'SETADMINLOGGEDIN', cdRegister);
  Exec.RegisterDelphiFunction(@GetAdminPass, 'GETADMINPASS', cdRegister);

  if not Exec.LoadData(Data) then begin
    Exec.Free;
     // You could raise an exception here.
    Exit;
  end;

  Exec.RunScript;
  Exec.Free;
  Temp.Clear;
end;

procedure RunApp(const scriptfile: string);
begin
  if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+scriptfile+'.ht_s') then
    begin
      ExecuteScript(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+scriptfile+'.ht_s');
    end
  else
    begin
      Print('ERROR: Script not found !', LightRed);
    end
end;

procedure RunServerScript(const scriptfile: string);
begin
  if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+scriptfile+'.ht_s') then
    begin
      ExecuteScript(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+scriptfile+'.ht_s');
    end
  else
    begin
      Print('ERROR: ServerScript not found !', LightRed);
    end;
end;
procedure CommandParser(command: string);
begin
      if (Command='exit') or (Command='quit') then
        begin
          Running:=False;
        end;
      if Command='about' then
        begin
          Print(ProductName, White);
          Print('Version: '+Version, White);
          Print('Written by: '+MadeBy, White);
          Print('', White);
        end;
      if (Command='cls') or (Command='clear') then
        ClrScr;
      if Split(Command, ' ', 1)='connect' then
        begin
          if Split(Command, ' ', 2) = Split(Command, ' ', 3) then
            Print('Please enter a port number to connect to.', LightRed)
          else begin
          for i:=1 to Length(IP) do
            if ((IP[i]=Split(Command, ' ', 2)) or (Hostname[i]=Split(Command, ' ', 2))) and (Status[i]=True) then
              begin
                ServerFilename:=IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+IP[i]+'.srv';
                ServerFile:=TINIFile.Create(ServerFilename);
                Randomize;
                CurrentServer:=IP[i];
                RecentlyCurrentServer:=IP[i];
                CurrentPort:=StrToInt(Split(Command, ' ', 3));
                ListProtectedServer:=ServerFile.ReadBool('Info', 'ListProtected', false);
                Username:=ServerFile.ReadString('Info', 'Username', '');
                Password:=ServerFile.ReadString('Info', 'Password', '');
                AdminPass:=ServerFile.ReadString('Info', 'AdminPass', IntToStr(Random(100)));
                UploadAble:=ServerFile.ReadBool('Info', 'UploadAble', false);
                DeleteAble:=ServerFile.ReadBool('Info', 'DeleteAble', false);
                for j:=1 to 10 do
                  begin
                    OpenPorts[j]:=StrToInt(Split(ServerFile.ReadString('Info', 'OpenPorts', '0'), ' ', j));

                    if OpenPorts[j]=CurrentPort then
                      begin
                          RunServerScript(CurrentServer);
                          exit;
                      end;
                  end;
              end;

              if CorrectPort=False then
                begin
                  Print('No response...', LightRed);
                  Disconnect;
                end;
          end
        end;
      if Command='disconnect' then
        begin
          if Connected=True then
            Disconnect
          else
            Print('You can''t disconnect from nothing.', LightRed);
        end;
      if Command='ls' then
        begin
          if ((Connected=True) and (SSHLoggedIn=True)) or (CurrentServer='127.0.0.1') then
            begin
              if (ListProtectedServer=false) or (AdminLoggedIn=True) then
                FileList(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files', '*')
              else
                Print('This server is FileList protected.', LightRed);
            end
          else
            Print('You aren''t connected to a server, or you are not connected at the right port.', LightRed);
        end;
      if Split(Command, ' ', 1)='cat' then
        begin
          if ((Connected=True) and (SSHLoggedIn=True)) or (CurrentServer='127.0.0.1') then
            begin
              if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, ' ', 2)) then
                begin
                if Split((Split(Command, ' ', 2)), '.', 2)='bin' then
                  begin
                    Print('Unable to cat binary files!', LightRed);
                    Exit;
                  end
                  else
                    begin
                      Temp.Clear;
                      Temp.LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, ' ', 2));
                      Print(Split(Command, ' ', 2)+' >', White);
                      Print(Temp.Text, White);
                      Temp.Clear;
                    end
                end
              else
                Print('File not found !', LightRed);
            end;
        end;
      if Command='commands' then
        if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\commands.txt') then
          begin
            Temp.Clear;
            Temp.LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\commands.txt');
            Print(Temp.Text, White);
            Temp.Clear;
          end
        else
          Print('ERROR: The command list wasn''t found! :(', LightRed);
      if Split(Command, ' ', 1)='rm' then
        if ((Connected=True) and (SSHLoggedIn=True)) or (CurrentServer='127.0.0.1') then
          begin
            if (FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, ' ', 2))) and (DeleteAble=True) then
              begin
                DeleteFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, ' ', 2));
                Print('File: '+Split(Command, ' ', 2)+' has been deleted from: '+CurrentServer+' !', LightRed);
              end
            else
              Print('File not found !', LightRed);
          end;
      if Split(Command, ' ', 1)='wget' then
        if (Connected=True) and (SSHLoggedIn=True) then
          begin
            if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files'+'\'+Split(Command, ' ', 2)) then
              begin
                RecentlyDownloaded:=Split(Command, ' ', 2);
                CopyFile(PChar(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files'+'\'+Split(Command, ' ', 2)),
                         PChar(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\127.0.0.1_files\'+Split(Command, ' ', 2)), false);
                Print('The file: '+Split(Command, ' ', 2)+' has been saved to your home directory', LightRed);
              end
            else
              Print('The requested file was not found on the server!', LightRed);
          end
        else
          Print('Please connect to and login on a server before using wget', LightRed);
      if Split(Command, ' ', 1)='upload' then
        if (Connected=True) and (SSHLoggedIn=True) then
          begin
            if (UploadAble=True) or (AdminLoggedIn=True) then
              begin
                if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\127.0.0.1_files'+'\'+Split(Command, ' ', 2)) then
                  begin
                    RecentlyUploaded:=Split(Command, ' ', 2);
                    CopyFile(PChar(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\127.0.0.1_files\'+Split(Command, ' ', 2)),
                             PChar(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files'+'\'+Split(Command, ' ', 2)), false);
                    Print('The file: '+Split(Command, ' ', 2)+' has been uploaded from your homedir to '+CurrentServer, LightRed);
                  end
                else
                  Print('The selected file wasn''t found in your homedir', LightRed);
              end
            else
              Print('You are not allowed to upload files to this server!', LightRed);
          end;
      if Split(command, ' ', 1)='pscan' then
        for i:=1 to Length(IP) do
          begin
            if (IP[i]=Split(Command, ' ', 2)) or (Hostname[i]=Split(Command, ' ', 2)) and (Connected=False) then
              begin
                Print(':: Port scanner ::', white);
                Print('Scanning for open ports at '+Split(Command, ' ', 2)+'...', white);
                ServerFilename:=IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+IP[i]+'.srv';
                ServerFile:=TINIFile.Create(ServerFilename);
                Counter:=0;

                for j:=1 to 10 do
                  begin
                    OpenPorts[j]:=StrToInt(Split(ServerFile.ReadString('Info', 'OpenPorts', '0'), ' ', j));
                 end;

                for j:=1 to Length(OpenPorts) do
                  begin
                    Sleep(130);
                    if OpenPorts[j]=OpenPorts[j+1] then else
                      begin
                        Print('Open: '+IntToStr(OpenPorts[j]), LightGreen);
                        Counter:=Counter+1;
                      end;
                  end;
                  Print('Open ports found: '+IntToStr(counter), White);
                  ServerFile.Free;
              end;
          end;
      if (Command='shutdown') then
        begin
          if CurrentServer='127.0.0.1' then
            Print('You can''t shutdown your own computer. If you want to exit the game, plase use the "exit" command.', white)
          else
            begin
              if (AdminLoggedIn=True) and (SSHLoggedIn=True) then
                begin
                  ShutdownServer(CurrentServer);
                end
              else
                Print('You need admin rights to shutdown the server!', LightRed);
            end;
        end;
      if Command='bookmarks' then
        begin
          MenuRunning:=True;
          while MenuRunning=True do
            begin
              Print('', white);
              Print('Bookmark menu:', 7);
              Print('1) View bookmarks', white);
              Print('2) Add bookmark', white);
              Print('3) Remove bookmark', white);
              Print('4) Exit menu', white);
              Readln(MenuItem);
              Print('', white);

              if MenuItem='1' then
                begin
                  Print('Bookmarks:', white);
                  Temp.Clear;
                  Temp.LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\bookmarks.txt');
                  Print(Temp.Text, LightCyan);
                  Temp.Clear;
                end;

              if MenuItem='2' then
                begin
                  Print('Add a new bookmark:', white);
                  Print2('Hostname: ', white); Readln(Temp1);
                  Print2('Description: ',white); Readln(Temp2);
                  Temp.Clear;
                  Temp.LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\bookmarks.txt');
                  Temp.Add(Temp2+' :: '+Temp1);
                  Temp.SaveToFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\bookmarks.txt');
                  Temp.Clear;
                  Print('Bookmark added!', white);
                end;

              if MenuItem='3' then
                begin
                  Temp.Clear;
                  Temp.LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\bookmarks.txt');

                  for p := 0 to Temp.Count -1 do
                    Print(IntToStr(p)+' '+Temp.Strings[p], LightCyan);

                  Print('', white);
                  Print2('Enter a line to remove (use x to cancel):', white); Readln(MenuItem);

                  if MenuItem='x' then
                  else
                    begin
                      Temp.Delete(StrToInt(MenuItem));
                      Temp.SaveToFile(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\bookmarks.txt');
                      Print('Bookmark removed!', White);
                    end;
                end;

              if MenuItem='4' then
                MenuRunning:=False;
            end;
        end;
      if Command='objective' then
        begin
          Print('Mission objective: '+ObjectiveMsg, white);
        end;
      if (Split(Command, ' ', 1)='crack') and (Length(Password)>0) then
        begin
          j:=0;
          max:=5;
          i:=0;
          PassCrackAble:=false;
          temp1:='';
          Finished:=False;

          if (Split(Command, ' ' , 2)='127.0.0.1') or (Split(Command, ' ' , 2)='localhost') then
            begin
              Print('You can''t crack your local password!', LightRed);
              exit;
            end;

          if Connected=true then
            begin
              Print('You have to disconnect before trying to crack a new server!', LightRed);
              exit;
            end;

          for i:=1 to Length(IP) do
            begin
              if (IP[i]=Split(Command, ' ', 2)) or (Hostname[i]=Split(Command, ' ', 2)) then
                begin
                  Print(':: Password cracker ::', white);
                  Print('Trying to crack the root password at '+Split(Command, ' ', 2)+'...', white);
                  Print('(Press any key to abort the cracking process)', White);
                  Sleep(1200);
                  ServerFilename:=IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+IP[i]+'.srv';
                  ServerFile:=TINIFile.Create(ServerFilename);
                  PassCrackAble:=ServerFile.ReadBool('Info', 'PassCrackAble' , false);
                  Randomize;
                  temp1:=ServerFile.ReadString('Info', 'AdminPass', RandomString(Random(12), 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'));
                  ServerFile.Free;
                end;
            end;

          repeat
            max:=(Length(temp1)*Length(temp1))*2;
            Randomize;
            Print(RandomString(Length(temp1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'), White);
            Delay(60);
            j:=j+1;
            if j>=max then
              begin
                if PassCrackAble=True then
                  begin
                    Print('Password found: '+temp1, LightBlue);
                  end
                else
                  begin
                    Print('The password could not be cracked!', Lightblue);
                    Exit;
                  end;

                Finished:=True;
              end;
          until KeyPressed or Finished=True;
        end;

      if (Copy(Command, 0, 2)='./') then
        begin
          if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, '/', 2)) then
            begin
      //        Decrypt(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, '/', 2));
              if (SSHLoggedIn=True) or (CurrentServer='127.0.0.1') then
                begin
                  RecentlyExeced:=Split(Command, '/', 2);
                  ExecuteScript(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, '/', 2));
                  MissionObjective;
                end;
      //        Encrypt(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\'+CurrentServer+'_files\'+Split(Command, '/', 2));
            end
          else
            Print('File not found!', LightRed);
        end;
      if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+Split(Command, ' ', 1)+'.ht_s') then
        begin
      //    Decrypt(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+Split(Command, ' ', 1)+'.ht_s');
          RunApp(Split(Command, ' ', 1));
      //    Encrypt(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+Split(Command, ' ', 1)+'.ht_s');
        end;
      if (Split(Command, ' ', 1)='compile') then
        begin
          if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+Split(Command, ' ', 2)) then
            begin
              Encrypt(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+Split(Command, ' ', 2));
            end;
        end;
      if (Split(Command, ' ', 1)='decompile') and (Debug=True) then
        begin
          if FileExists(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+Split(Command, ' ', 2)) then
            begin
              Decrypt(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\programs\'+Split(Command, ' ', 2));
            end;
        end;
      if (Command='status') and (Debug=True) then
        begin
          Print('CurrentServer: '+CurrentServer, Lightblue);
          Print('CurrentPort: '+IntToStr(CurrentPort), Lightblue);
          Print('ListProtectedServer: '+BoolToStr(ListProtectedServer), Lightblue);
          Print('Username: '+Username, Lightblue);
          Print('Password: '+Password, Lightblue);
          Print('AdminPass: '+AdminPass, Lightblue);
        end;
      if (Split(Command, ' ', 1)='set') and (Debug=True) then
        begin
          if Split(Command, ' ', 2)='password' then
            Password:=Split(Command, ' ', 3);
          if Split(Command, ' ', 2)='username' then
            Username:=Split(Command, ' ', 3);
          if Split(Command, ' ', 2)='adminpass' then
            AdminPass:=Split(Command, ' ', 3);
          if Split(Command, ' ', 2)='adminloggedin' then
            AdminLoggedIn:=True;
          Print('Variable set !', LightRed);
        end;

end;






begin
  Running:=True;
  Connected:=False;
  Temp := TStringList.Create;
  CurrentServer:='127.0.0.1';
  CurrentUser:='root';
  Username:='root';
  Password:='root';
  DeleteAble:=True;
  UploadAble:=True;
  TextColor(LightGreen);

  // INIT
  LoadIPs(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\list.ht_d');
  LoadHostnames(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'\servers\list.ht_d');

  LevelsCompletedFilename:=IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)))+'levels.ini';
  LevelsCompleted:=TINIFile.Create(LevelsCompletedFilename);

  for i:=0 to 20 do
    begin
      MissionsCompleted[i]:=LevelsCompleted.ReadBool('Completed', 'M'+IntToStr(i), false);
      if MissionsCompleted[i]=true then
        begin
          ClrScr;
          PrintWelcome;
          LoadMission('m'+IntToStr(i));
        end;
    end;

  for i:=1 to 255 do
    Status[i]:=true;
  // INIT END

  while Running=True do
    begin
      CorrectPort:=False;
      Print2(CurrentUser+'@'+CurrentServer+'$ ', LightGreen);
      Readln(TypedCommand);
      CommandParser(TypedCommand);
      MissionObjective;
    end;

  CleanUp;
end.
