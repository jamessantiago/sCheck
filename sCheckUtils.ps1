$global:sCheckPath = $MyInvocation.MyCommand.Definition | Split-Path

function Get-SCheckPlugin
{
    <#
        .SYNOPSIS
        
        Retrieves installed sCheck plugins and available plugins from the Virtu-Al.net repository.

        .DESCRIPTION
        
        Get-SCheckPlugin parses your sCheck plugins folder, as well as searches the online plugin respository in Virtu-Al.net.
        After finding the plugin you are looking for, you can download and install it with Add-sCheckPlugin. Get-SCheckPlugins
        also supports finding a plugin by name. Future version will support categories (e.g. Datastore, Security, vCloud)
        
        .PARAMETER name

        Name of the plugin.
		
        .PARAMETER proxy

        URL for proxy usage.

        .EXAMPLE

        Get list of all sCheck Plugins

        Get-SCheckPlugin

        
        .EXAMPLE

        Get plugin by name

        Get-SCheckPlugin PluginName

        
        .EXAMPLE

        Get plugin by name using proxy

        Get-SCheckPlugin PluginName -proxy "http://127.0.0.1:3128"


        .EXAMPLE

        Get 

        Get-SCheckPlugins PluginName

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(mandatory=$false)] [String]$name,
        [Parameter(mandatory=$false)] [String]$proxy,
        [Parameter(mandatory=$false)] [Switch]$installed,
        [Parameter(mandatory=$false)] [Switch]$notinstalled,
		[Parameter(mandatory=$false)] [String]$category
    )
    Process
    {
        $pluginObjectList = @()

        foreach ($localPluginFile in (Get-ChildItem $sCheckPath\Plugins\*.ps1 -Recurse))
        {
            $localPluginContent = Get-Content $localPluginFile
            
            if ($localPluginContent | Select-String -pattern "title")
            {
                $localPluginName = ($localPluginContent | Select-String -pattern "Title").toString().split("`"")[1]
            }
            if($localPluginContent | Select-String -pattern "description")
            {
                $localPluginDesc = ($localPluginContent | Select-String -pattern "description").toString().split("`"")[1]
            }
            elseif ($localPluginContent | Select-String -pattern "comments")
            {
                $localPluginDesc = ($localPluginContent | Select-String -pattern "comments").toString().split("`"")[1]
            }
            if ($localPluginContent | Select-String -pattern "author")
            {
                $localPluginAuthor = ($localPluginContent | Select-String -pattern "author").toString().split("`"")[1]
            }
            if ($localPluginContent | Select-String -pattern "PluginVersion")
            {
                $localPluginVersion = @($localPluginContent | Select-String -pattern "PluginVersion")[0].toString().split(" ")[-1]
            }
			 if ($localPluginContent | Select-String -pattern "PluginCategory")
            {
                $localPluginCategory = @($localPluginContent | Select-String -pattern "PluginCategory")[0].toString().split("`"")[1]
            }
            $pluginObject = New-Object PSObject
            $pluginObject | Add-Member -MemberType NoteProperty -Name name -value $localPluginName
            $pluginObject | Add-Member -MemberType NoteProperty -Name description -value $localPluginDesc
            $pluginObject | Add-Member -MemberType NoteProperty -Name author -value $localPluginAuthor
            $pluginObject | Add-Member -MemberType NoteProperty -Name version -value $localPluginVersion
			$pluginObject | Add-Member -MemberType NoteProperty -Name category -Value $localPluginCategory
            $pluginObject | Add-Member -MemberType NoteProperty -Name status -value "Installed"
            $pluginObject | Add-Member -MemberType NoteProperty -Name location -Value $LocalpluginFile.name
            $pluginObjectList += $pluginObject
        }

        if (!$installed)
        {
            try
            {
                $webClient = new-object system.net.webclient
				if ($proxy)
				{
					$proxyURL = new-object System.Net.WebProxy $proxy
					$proxyURL.UseDefaultCredentials = $true
					$webclient.proxy = $proxyURL
				}
                # $response = $webClient.openread("http://www.virtu-al.net/scheck/plugins/plugins.xml")
                $streamReader = new-object system.io.streamreader $response
                [xml]$plugins = $streamReader.ReadToEnd()

                foreach ($plugin in $plugins.pluginlist.plugin)
                {
                    if (!($pluginObjectList | where {$_.name -eq $plugin.name}))
                    {
                        $pluginObject = New-Object PSObject
                        $pluginObject | Add-Member -MemberType NoteProperty -Name name -value $plugin.name
                        $pluginObject | Add-Member -MemberType NoteProperty -Name description -value $plugin.description
                        $pluginObject | Add-Member -MemberType NoteProperty -Name author -value $plugin.author
                        $pluginObject | Add-Member -MemberType NoteProperty -Name version -value $plugin.version
						$pluginObject | Add-Member -MemberType NoteProperty -Name category -Value $plugin.category
                        $pluginObject | Add-Member -MemberType NoteProperty -Name status -value "Not Installed"
                        $pluginObject | Add-Member -MemberType NoteProperty -name location -value $plugin.href
                        $pluginObjectList += $pluginObject
                    }
                }
            }
            catch [System.Net.WebException]
            {
                write-error $_.Exception.ToString()
                return
            }

        }

        if ($name){
            $pluginObjectList | where {$_.name -eq $name}
        } Else {
			if ($category){
				$pluginObjectList | Where {$_.Category -eq $category}
			} Else {
	            if($notinstalled){
	                $pluginObjectList | where {$_.status -eq "Not Installed"}
	            } else {
	                $pluginObjectList
	            }
	        }
		}
    }

}


function Add-SCheckPlugin
{
    <#
        .SYNOPSIS
        
        Installs a sCheck plugin from the Virtu-Al.net repository.

        .DESCRIPTION
        
        Add-SCheckPlugin downloads and installs a sCheck Plugin (currently by name) from the Virtu-Al.net repository. 
        
        The downloaded file is saved in your sCheck plugins folder, which automatically adds it to your sCheck report. sCheck plugins may require
        configuration prior to use, so be sure to open the ps1 file of the plugin prior to running your next report. 

        
        .PARAMETER name

        Name of the plugin.

        .EXAMPLE

        Install via pipeline from Get-SCheckPlugins

        Get-SCheckPlugin "Plugin name" | Add-SCheckPlugin

        
        .EXAMPLE

        Install Plugin by name

        Add-SCheckPlugin "Plugin name"

    #>
    [CmdletBinding(DefaultParametersetName="name")]
    Param
    (
        [Parameter(parameterSetName="name",Position=0,mandatory=$true)] [String]$name,
        [Parameter(parameterSetName="object",Position=0,mandatory=$true,ValueFromPipeline=$true)] [PSObject]$pluginobject
    )
    Process
    {
        if($name)
        {
            Get-SCheckPlugin $name | Add-SCheckPlugin
        }
        elseif ($pluginObject)
        {
            Add-Type -AssemblyName System.Web
            $filename = $pluginObject.location.split("/")[-1]
            $filename = [System.Web.HttpUtility]::UrlDecode($filename)
            try
            {
                Write-Host "Downloading File..."
                $webClient = new-object system.net.webclient
                $webClient.DownloadFile($pluginObject.location,"$sCheckPath\Plugins\$filename")
                Write-Host -ForegroundColor green "The plugin `"$($pluginObject.name)`" has been installed to $sCheckPath\Plugins\$filename"
                Write-Host -ForegroundColor green "Be sure to check the plugin for additional configuration options."

            }
            catch [System.Net.WebException]
            {
                write-error $_.Exception.ToString()
                return
            }
        }
        
    }

}

function Remove-SCheckPlugin
{
    <#
        .SYNOPSIS
        
        Removes a sCheck plugin.

        .DESCRIPTION
        
        Remove-SCheckPlugin Uninstalls a sCheck Plugin.
        
        Basically, just looks for the plugin name and deletes the file. Sure, you could just delete the ps1 file from the plugins folder, but what fun is that?

        
        .PARAMETER name

        Name of the plugin.

        .EXAMPLE

        Remove via pipeline

        Get-SCheckPlugin "Plugin name" | Remove-SCheckPlugin

        
        .EXAMPLE

        Remove Plugin by name

        Remove-SCheckPlugin "Plugin name"

    #>
    [CmdletBinding(DefaultParametersetName="name",SupportsShouldProcess=$true,ConfirmImpact="High")]
    Param
    (
        [Parameter(parameterSetName="name",Position=0,mandatory=$true)] [String]$name,
        [Parameter(parameterSetName="object",Position=0,mandatory=$true,ValueFromPipeline=$true)] [PSObject]$pluginobject
    )
    Process
    {
        if($name)
        {
            Get-SCheckPlugin $name | Remove-SCheckPlugin
        }
        elseif ($pluginObject)
        {
           Remove-Item -path ("$sCheckPath\plugins\$($pluginobject.location)") -confirm:$false
        }
        
    }

}

Function Get-sCheckCommand {
	Get-Command *sCheck*
}

Get-sCheckCommand
