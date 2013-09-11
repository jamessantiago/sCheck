# Start of Settings 
#Set the text file location for a list of windows servers
$percLeft = 15
# End of Settings

function Git-FreeSpace ($server)
{
    $drives = $null
    try
    {
        $drives = get-wmiobject win32_volume -computer $server -filter 'drivetype = 3' -erroraction 0
        $drives | select @{Name="Server";Expr={$_.__SERVER}}, driveletter, label, @{Name='GBfreespace';Expr={$($_.freespace/1GB).ToString("0.0")}}, @{Name='GBcapacity';Expr={$($_.capacity/1GB).ToString("0.0")}},  @{Name='Available%';Expr={$($_.freespace/$_.Capacity * 100).ToString("0")}}
    }
    catch
    {
         
    }
      
}

foreach ($server in $WindowsServers)
{
    if (Test-Connection -count 1 -ComputerName $server -quiet)
    {
        $freeSpaceResults += git-freespace $server
    }
}

$freeSpaceResults |? {$_."Available%" -lt $percLeft}

$Title = "Server FreeSpace"
$Header =  "Servers that have less than $percLeft % left on a drive"
$Comments = "Clean up or expand drives to prevent issues with loss of writable disk space"
$Display = "Table"
$Author = "James Santiago"
$PluginVersion = 1.0
$PluginCategory = "Windows Servers"