unit About;

interface

uses sysutils, mainUnit;

const
  SoftwareTitle = 'EnoTrace';
  Authors: string = 'Kim Johnson, Nina Hansen, Jake Mukika)';
  Version: string = '0.1 Beta';

procedure PrintAbout; 
 
implementation
 
procedure PrintAbout;
begin
  Print(SoftwareTitle);
  Print('Version :'+Version); 
  Print('Authors: '+Authors);
end;

end.