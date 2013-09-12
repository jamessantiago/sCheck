# Start of Settings 
#Set the maximum size (MB) for the transaction log
$logSize = 500
#Set the maximum log space percentage used
$logPerc = 85
# End of Settings


foreach ($server in $MSSQLServers)
{
    $conn = New-Object system.data.sqlclient.sqlconnection
    $conn.connectionstring = "Server=$server;Integrated Security=SSPI;Database=master;Connection Timeout=5;Application Name=sCheck"
    $conn.statisticsenabled = $true
    try
    {
        $conn.open()
    }
    catch {
        continue
    }
    if ($conn.state -eq "Open")
    {
        $ds = new-object system.data.dataset
        $da = New-Object system.data.sqlclient.sqldataadapter("dbcc sqlperf(logspace)", $conn)
        try
        {
            $da.fill($ds) | out-null
            $da.dispose()
            $conn.close()
            $conn.dispose()
            foreach ($row in $ds.tables[0].Rows)
            {
                $temp = "" | select "Server", "Database Name", "Log Size (MB)", "Log Space Used (%)", "Status"
                $temp.Server = $serverName
                $temp."Database Name" = $row."Database Name"
                $temp."Log Size (MB)" = $row."Log Size (MB)"
                $temp."Log Space Used (%)" = $row."Log Space Used (%)"
                $temp."Status" = "Online"
                $sqlResults += $temp
            }                
        }
        catch
        {
            
        }
    }
}

$sqlResults |? {$_."Log Size (MB)" -gt $logSize -and $_."Log Space Used (%)" -gt $logPerc}

$Title = "Server FreeSpace"
$Header =  "Databases that have a transaction log larger than $logSize MB and more than $logPerc % of space used"
$Comments = "Check whether the database's transaction log is being properly backed up"
$Display = "Table"
$Author = "James Santiago"
$PluginVersion = 1.0
$PluginCategory = "MSSQL Servers"