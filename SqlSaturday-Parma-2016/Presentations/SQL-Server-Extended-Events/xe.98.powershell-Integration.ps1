# Script:		xe.98.powershell-Integration.ps1
# Description:	Extended Events demo
# Author:		Gianluca Hotz (SolidQ)
# Copyright:	Attribution-NonCommercial-ShareAlike 3.0

# Import SQLPS if not already done
Import-Module -Name SQLPS

$Hostname = hostname;
$InstanceName = "DEFAULT";

# Find Packages
dir "SQLSERVER:\XEvent\$Hostname\$InstanceName\Packages";

# Find Sessions
dir "SQLSERVER:\XEvent\$Hostname\$InstanceName\Sessions";

# Get system_health session
$xeSystemHealthSession = Get-Item "SQLSERVER:\XEvent\$Hostname\$InstanceName\Sessions\system_health";

# Discover members
$xeSystemHealthSession | Get-Member;

#
# Create a test session
# Basic instructions to create/alter a session
# http://technet.microsoft.com/en-us/library/ff877887.aspx
#
$Hostname = hostname;
$InstanceName = "DEFAULT";

cd "SQLSERVER:\XEvent";
cd $Hostname;

$xeStore = dir | where {$_.DisplayName -ieq $InstanceName}

$xeNewSession = new-object Microsoft.SqlServer.Management.XEvent.Session -argumentlist $xeStore, "TestSession";
$xeNewEvent = $xeNewSession.AddEvent("sqlserver.sql_statement_completed");
$xeNewEvent.AddAction("sqlserver.sql_text");
$xeNewSession.AddTarget("package0.ring_buffer");
$xeNewSession.Create();

# To start the session
$xeNewSession.Start();

# To stop the session
$xeNewSession.Stop();
