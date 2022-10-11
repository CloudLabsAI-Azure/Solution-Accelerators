Start-Transcript -Path C:\WindowsAzure\Logs\Logon.txt -Append

#Install Postman
choco install postman -y -force

. C:\Packages\AzureCreds.ps1

$userName = $AzureUserName #READ FROM FILE
$password = $AzurePassword #READ FROM FILE
$sid = $AzureSubscriptionID #READ FROM FILE
$deployid = $DeploymentID #READ FROM FILE
$vmUsername = $AdminUsername #READ FROM FILE
$vmPassword = $AdminPassword #READ FROM FILE
$applicationid = $ServicePrincipalApplicationID #READ FROM FILE

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

$rgName = (Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*smart-spaces*"}).ResourceGroupName

#Download DeployScript
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Smart-Spaces-Sustainability/scripts/deployscript.ps1", "C:\LabFiles\deployscript.ps1")
$rgName = (Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*smart-spaces*"}).ResourceGroupName

#Retrieve Key Vault Name
$kvs = Get-AzResource -ResourceGroupName $rgName -ResourceType Microsoft.KeyVault/vaults
$kvName = $kvs.Name

#Retrieve IoTHubName
$iot = Get-AzResource -ResourceGroupName $rgName -ResourceType Microsoft.Devices/IotHubs
$iotname = $iot.Name

#Retrieve FuncHVACName
$funchvac = Get-AzResource -ResourceGroupName $rgName -ResourceType Microsoft.Web/sites
$funchvacfn = $funchvac | Where-Object {$_.Name -like "FuncSMARTSPACE-HVAC*"}
$funchvacname = $funchvacfn.Name

#Retrieve FuncSmartSpaceName
$funcsmart = $funchvac | Where-Object {$_.Name -like "FuncSMARTSPACE$DeploymentID"}
$funcsmartname = $funcsmart.Name

#Retrieve StreamAnalyticsJobName
$asastream = Get-AzResource -ResourceGroupName $rgName -ResourceType Microsoft.StreamAnalytics/streamingjobs
$asaname = $asastream.Name

#Assign Contributor Role to SP
New-AzRoleAssignment -ApplicationId $applicationid -ResourceGroupName $rgName -ResourceName $asaname -ResourceType Microsoft.StreamAnalytics/streamingjobs -RoleDefinitionName "Contributor"

#Replace Values in deployscript.ps1
(Get-Content -Path "C:\LabFiles\deployscript.ps1") | ForEach-Object {$_ -Replace 'enter_uname', $userName} | Set-Content -Path "C:\LabFiles\deployscript.ps1"
(Get-Content -Path "C:\LabFiles\deployscript.ps1") | ForEach-Object {$_ -Replace 'enter_password', $password} | Set-Content -Path "C:\LabFiles\deployscript.ps1"
(Get-Content -Path "C:\LabFiles\deployscript.ps1") | ForEach-Object {$_ -Replace 'enter_iothubname', $iotname} | Set-Content -Path "C:\LabFiles\deployscript.ps1"
(Get-Content -Path "C:\LabFiles\deployscript.ps1") | ForEach-Object {$_ -Replace 'enter_rgname', $rgName} | Set-Content -Path "C:\LabFiles\deployscript.ps1"
(Get-Content -Path "C:\LabFiles\deployscript.ps1") | ForEach-Object {$_ -Replace 'enter_kvname', $kvName} | Set-Content -Path "C:\LabFiles\deployscript.ps1"
(Get-Content -Path "C:\LabFiles\deployscript.ps1") | ForEach-Object {$_ -Replace 'enter_funchvacname', $funchvacname} | Set-Content -Path "C:\LabFiles\deployscript.ps1"
(Get-Content -Path "C:\LabFiles\deployscript.ps1") | ForEach-Object {$_ -Replace 'enter_funcsmartspacename', $funcsmartname} | Set-Content -Path "C:\LabFiles\deployscript.ps1"

sleep 60

#ExecuteDeployScript
cd C:\LabFiles
.\deployscript.ps1

Unregister-ScheduledTask -TaskName "Setup1" -Confirm:$false

Stop-Transcript
Restart-Computer -Force
