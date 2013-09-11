# Start of Settings 
#Set the text file location for a list of windows servers
$serverLoc = $null
# End of Settings

$WindowsServers = Get-Content $serverLoc

$Title = "Collect Servers"
$Header =  "Collect Servers"
$Comments = "Server collection"
$Display = "None"
$Author = "James Santiago"
$PluginVersion = 1.0
$PluginCategory = "Windows Servers"