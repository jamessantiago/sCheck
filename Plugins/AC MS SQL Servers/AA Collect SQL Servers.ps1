# Start of Settings 
#Set the text file location for a list of Microsoft SQL servers
$mssqlLoc = $null
# End of Settings

$MSSQLServers = Get-Content $mssqlLoc

$Title = "Collect MSSQL Servers"
$Header =  "Collect MSSQL Servers"
$Comments = "Server collection"
$Display = "None"
$Author = "James Santiago"
$PluginVersion = 1.0
$PluginCategory = "Windows Servers"