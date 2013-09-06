$Title = "Shodan query results"
$Author = "James Santiago"
$PluginVersion = 1.0
$Header =  "Shodan query results"
$Comments = "Results are from the Shodan database and may indicate a vulnerability or system that should not be discoverable"
$Display = "List"
$PluginCategory = "Security"

# Start of Settings 
# API Key to connect to Shodan
$APIKey = $null
# Shodan discovery query (e.g. "net:a.b.c.d/24")
$sQuery = $null
# End of Settings

$ShodanModule = $ScriptPath + "\AG Security\Shodan\Shodan.psm1"
Import-Module $ShodanModule

if ($Host.Version.Major -eq 3)
{
    $results = Search-Shodan -Query $sQuery -APIKey $APIKey
    $results
}
else
{
    Write-Host -ForegroundColor red "AA Shodan Discovery can only be ran under powershell v3"
}