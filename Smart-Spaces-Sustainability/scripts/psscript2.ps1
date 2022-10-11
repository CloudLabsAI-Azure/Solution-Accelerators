Start-Transcript -Path C:\WindowsAzure\Logs\CustomScriptExtensionPart2.txt -Append

. C:\Packages\AzureCreds.ps1

$userName = $AzureUserName #READ FROM FILE
$password = $AzurePassword #READ FROM FILE
$sid = $AzureSubscriptionID #READ FROM FILE
$deployid = $DeploymentID #READ FROM FILE
$vmPassword = $AdminPassword #READ FROM FILE
$spappid = $ServicePrincipalApplicationID #READ FROM FILE
$spsecret = $ServicePrincipalSecretKey #READ FROM FILE
$tenantid = $AzureTenantID #READ FROM FILE

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

$rgName = (Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*smart-spaces*"}).ResourceGroupName

#Download Second-Deployment Template
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/deploy-03.json", "C:\LabFiles\deploy-03.json")
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/deploy-03.parameters.json", "C:\LabFiles\deploy-03.parameters.json")

$rgName = (Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*smart-spaces*"}).ResourceGroupName

#Retrieve Key Vault Name
$kvs = Get-AzResource -ResourceGroupName $rgName -ResourceType Microsoft.KeyVault/vaults
$kvName = $kvs.Name

#Retrieve SQL Server Name
$sqls = Get-AzResource -ResourceGroupName $rgName -ResourceType Microsoft.Sql/servers
$sqlsname = $sqls | Where-Object {$_.Name -like 'sqlserver*'}
$sqlsrv = $sqlsname.Name

#Retrieve SQL Database Name
$sqldb = Get-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlsname.Name | Where-Object {$_.DatabaseName -like 'sqlDB*'}
$sqldbname = $sqldb.DatabaseName

(Get-Content -Path "C:\LabFiles\deploy-03.json") | ForEach-Object {$_ -Replace 'enter_keyvaultname', $kvName} | Set-Content -Path "C:\LabFiles\deploy-03.json"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace 'enter_keyvaultname', $kvName} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-03.json") | ForEach-Object {$_ -Replace 'enter_sqlservername', $sqlsrv} | Set-Content -Path "C:\LabFiles\deploy-03.json"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace 'enter_sqlservername', $sqlsrv} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-03.json") | ForEach-Object {$_ -Replace 'enter_sqldbname', $sqldbname} | Set-Content -Path "C:\LabFiles\deploy-03.json"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace 'enter_sqldbname', $sqldbname} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-03.json") | ForEach-Object {$_ -Replace 'enter_deploymentid', $deployid} | Set-Content -Path "C:\LabFiles\deploy-03.json"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace 'enter_deploymentid', $deployid} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-03.json") | ForEach-Object {$_ -Replace 'enter_appid', $spappid} | Set-Content -Path "C:\LabFiles\deploy-03.json"
(Get-Content -Path "C:\LabFiles\deploy-03.json") | ForEach-Object {$_ -Replace 'enter_clientsecret', $spsecret} | Set-Content -Path "C:\LabFiles\deploy-03.json"
(Get-Content -Path "C:\LabFiles\deploy-03.json") | ForEach-Object {$_ -Replace 'enter_tenantid', $tenantid} | Set-Content -Path "C:\LabFiles\deploy-03.json"

sleep 60

#Deploy ARM Template 2
$rgName = (Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*smart-spaces*"}).ResourceGroupName
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateUri "C:\LabFiles\deploy-03.json" -TemplateParameterUri "C:\LabFiles\deploy-03.parameters.json"

sleep 300

#Download Logon Task
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/scripts/logon.ps1","C:\LabFiles\logon.ps1")

#Enable Auto-Logon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$vmPassword" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

#checkdeployment
$status = (Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name "deploy-03").ProvisioningState
$status
if ($status -eq "Succeeded")
{
 
    $Validstatus="Pending"  ##Failed or Successful at the last step
    $Validmessage="Main Deployment is successful, logontask is pending"

# Scheduled Task
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\demouser"
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\LabFiles\logon.ps1"
Register-ScheduledTask -TaskName "Setup1" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force
Set-ExecutionPolicy -ExecutionPolicy bypass -Force

Unregister-ScheduledTask -TaskName "Setup" -Confirm:$false

}
else {
    Write-Warning "Validation Failed - see log output"
    $Validstatus="Failed"  ##Failed or Successful at the last step
    $Validmessage="ARM template Deployment Failed"
      }

Stop-Transcript
Restart-Computer -Force
