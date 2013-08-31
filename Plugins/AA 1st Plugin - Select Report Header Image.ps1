$Title = "Select Report Header Image"
$Header ="Select Report Header Image"
$Comments = "User selection of report header image"
$Display = "None"
$Author = "Phil Randal"
$PluginVersion = 1.1
$PluginCategory = "vCheck"

# Start of Settings
# End of Settings

# This plugin selects the report header image
# Expects to find specified Header Image in sCheck\Headers
# Reverts to default Header.jpg in sCheck Directory if file not found

#Changelog
## 1.0 : Quick and dirty hack - must be first plugin run
## 1.1 : Modified to use the Styles folder
## 1.2 : Removed headerpicture settings
# $ScriptPath is set in sCheck.ps1, is the path to sCheck folder

$HeaderFile = $StylePath + "\Header.jpg"
If (!(Test-Path $HeaderFile)) {
  $HeaderFile = $ScriptPath + "Styles\Default\Header.jpg"
}

# Create new Header Image

$HeaderImg = Get-Base64Image ($HeaderFile)

# overwrite $MyReport with header containing selected pic

$MyReport = Get-CustomHTML "sCheck"
$MyReport += Get-CustomHeader0 ($Server)
