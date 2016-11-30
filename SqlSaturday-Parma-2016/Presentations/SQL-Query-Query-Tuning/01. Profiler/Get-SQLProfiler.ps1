Function Get-SQLProfiler ()    
<#
	----------------------------------------------------------
	Load SQL SERVER Profiler Traces Files. (.trc)
	----------------------------------------------------------
	Version 1.0
	Laerte Poltronieri Junior
	www.laertejuniordba.spaces.live.com
 
	$TraceFileName   = MANDATORY String Full SQL SERVER Trace File Path  "C:\Temp\Profiler.trc" or "C:\temp\*.trc"   
	$FileToTable = OPTIONAL Boolean Flag to insert all data into SQL tables, divided by .trc file
	$ServerName = OPTIONAL Server Name String - If not especified and  $FileToTable = true default server will be used
	$DatabaseNe = OPTIONAL Database Name String - If not especified and  $FileToTable = true TEMPDB will be used
#>
{
[CmdletBinding()]
PARAM(
	[Parameter(Position=1,Mandatory=$true, ValueFromPipelineByPropertyName=$true,HelpMessage="SQL Server Profiler Trace File")]
    [Alias("FullName")]
    [ValidateScript({$_ -match ".TRC"})]
    [String] $TraceFileName,
    
    [Parameter(Position=2,Mandatory=$false, ValueFromPipelineByPropertyName=$true,HelpMessage="Flag to insert into SQL Table. Default False")]
    [Alias("InsertFile")]
    [switch] $FileToTable = $false,

	[Parameter(Position=4,Mandatory=$false, ValueFromPipelineByPropertyName=$true,HelpMessage="Server Name Default Localhost")]
    [Alias("SvrName")]
    [String] $ServerName = $env:COMPUTERNAME,
 
    [Parameter(Position=5,Mandatory=$false, ValueFromPipelineByPropertyName=$true,HelpMessage="Database Name Default TEMPDB")]
    [Alias("DbName")]
    [String] $DatabaseName = "TEMPDB"
	) 

begin
	{
  
    
 49:   $verbosePreference="continue" 
 50:   if ($fileToTable -AND $servername -eq $env:COMPUTERNAME -and $DatabaseName -eq  "TEMPDB" ) { 
 51:    $msg = "Server and Database parameters are not informed default values will be used : Server " + $env:COMPUTERNAME + " Database : TEMPDB"
 52:    write-warning $msg
 53:   }  
 54: 
 55:   
 56:   [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfoExtended") | out-null     
 57:   [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | out-null     
 58:   [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null 
 59:  }
 60:  process 
 61:  {
 62: 
 63:   try 
 64:   {
 65:    
 66:    # Verify if was passed multples .trc
 67:    $MultipleFiles = ($TraceFileName.substring($TraceFileName.length  - 5, 5) -eq "*.trc")
 68:    
 69:    #Setup Final Result and line number
 70:    $LineNumber = 1
 71:    $FinalResult = @()
 72:    
 73:      
 74:    # Get All .trc files (one or various)
 75:    foreach ($TraceFilePath in Get-ChildItem $TraceFileName -ErrorAction Stop ) {
 76:    
 77:     try 
 78:     {
 79:    
 80:   
 81:      #get trace name to create table
 82:      $TraceFileNameTRC = ($TraceFilePath.PSChildName).trim()
 83:      $TraceFileNameTRC = $TraceFileNameTRC.Trim()
 84: 
 85:      [String] $TraceFilePathString = $TraceFilePath
 86: 
 87:      $TableName = "PowerShellTraceTable_" + $TraceFileNameTRC.substring(0,$TraceFileNameTRC.length -4)
 88:      
 89:      $TraceFileReader = New-Object Microsoft.SqlServer.Management.Trace.TraceFile
 90:      $TraceFileReader.InitializeAsReader($TraceFilePathString) 
 91:      
 92:      if ($TraceFileReader.Read()-eq $true) 
 93:      {
 94:      
 95:       while ($TraceFileReader.Read())
 96:       {
 97:        
 98:       
 99:        $ObjectTrace = New-Object PSObject
100:        
101:       
102:        $ObjectTrace | add-member Noteproperty LineNumber   $LineNumber   
103:        $ObjectTrace | add-member Noteproperty TraceFile   $TraceFileNameTRC  
104: 
105:        
106:        $TotalFields = ($TraceFileReader.FieldCount) -1
107: 
108:        for($Count = 0;$Count -le $TotalFields;$Count++)
109:        {
110:         $FieldName = $TraceFileReader.GetName($Count)
111:         $FieldValue = $TraceFileReader.GetValue($TraceFileReader.GetOrdinal($FieldName))
112:         if ($FieldValue -eq $Null){ $FieldValue = ""}
113:          
114:         $ObjectTrace | add-member Noteproperty  $FieldName  $FieldValue
115:        }
116:        
117:        $FinalResult += $ObjectTrace
118:        $LineNumber ++ 
119:       
120:       }
121:       if ($FileToTable)
122:       {
123:       
124:        try {
125:         $SQLConnection = New-Object Microsoft.SqlServer.Management.Common.SqlConnectionInfo
126:         $SQLConnection.ServerName = $ServerName
127:         $SQLConnection.DatabaseName = $DatabaseName
128:         
129:         
130:         $TraceFileWriter = New-Object Microsoft.SqlServer.Management.Trace.TraceTable
131:         
132:                
133:         $TraceFileReader.InitializeAsReader($TraceFilePathString)
134:         $TraceFileWriter.InitializeAsWriter($TraceFileReader,$SQLConnection,$TableName) 
135:        
136:         while ( $TraceFileWriter.Write()) {}
137:        } 
138:        Catch {
139:          $msg = $error[0]
140:          write-warning $msg
141:        }  
142:        Finally {
143:         $TraceFileWriter.close()
144:        } 
145:        
146: 
147:       }
148: 
149:      } 
150:      
151:      
152:     } Catch {
153:         $msg = $error[0]
154:         write-warning $msg  
155:       } Finally {
156:         $TraceFileReader.close() 
157:     }
158:   
		} 

			Write-Output $FinalResult   
   
		} Catch {
			$msg = $error[0]
			write-warning $msg  
		} Finally {
			$TraceFileReader.Dispose 
			$TraceFileWriter.Dispose
			$SQLConnection.Dispose
		}
	}  
  
}