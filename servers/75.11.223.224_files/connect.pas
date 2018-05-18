unit Connect;

interface

uses sysutils, system, mainUnit;

// Not all the servers are online right now because the software is still under development.
const
  PrimaryServer: string = 'traceserver.enotrace.enosoft.com';
  SecondaryServer: string = 'backup.traceserver.enotrace.enosoft.com';
 
implementation
 
function Connect: boolean;
begin	
	
end;

end.