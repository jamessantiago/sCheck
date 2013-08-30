# You can change the following defaults by altering the below settings:
#

# Set the following to true to enable the setup wizard for first time run
$SetupWizard =$true

# Start of Settings
# Please Specify the IP address or Hostname of the server to connect to
$Server ="192.168.0.9"
# Please Specify the SMTP server address
$SMTPSRV ="mysmtpserver.mydomain.local"
# Please specify the email address who will send the sCheck report
$EmailFrom ="me@mydomain.local"
# Please specify the email address who will receive the sCheck report
$EmailTo ="me@mydomain.local"
# Please specify an email subject
$EmailSubject="$Server sCheck Report"
# Would you like the report displayed in the local browser once completed ?
$DisplaytoScreen =$True
# Use the following item to define if an email report should be sent once completed
$SendEmail =$true
# If you would prefer the HTML file as an attachment then enable the following:
$SendAttachment =$false
# Use the following area to define the title color
$Colour1 ="000000"
# Use the following area to define the Heading color
$Colour2 ="7BA7C7"
# Use the following area to define the Title text color
$TitleTxtColour ="FFFFFF"
# Set the style template to use.
$Style ="Default"
# Set the following setting to $true to see how long each Plugin takes to run as part of the report
$TimeToRun = $true
# Report an plugins that take longer than the following amount of seconds
$PluginSeconds = 30
# End of Settings

$Date = Get-Date
