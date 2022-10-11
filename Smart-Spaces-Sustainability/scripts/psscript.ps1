Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $ODLID,

    [string]
    $DeploymentID,

    [string]
    $azuserobjectid,

    [string]
    $InstallCloudLabsShadow,

    [string]
    $adminUsername,

    [string]
    $adminPassword,

    [string]
    $trainerUserName,

    [string]
    $trainerUserPassword,

    [string]
    $SPDisplayName,

    [string]
    $SPApplicationID,

    [string]
    $SPSecretKey,

    [string]
    $SPObjectID
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
InstallChocolatey
InstallAzPowerShellModule
InstallAzCLI
InstallSQLSMS
InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow

Enable-CloudLabsEmbeddedShadow $adminUsername $trainerUserName $trainerUserPassword

#Create Cred File

Function CreateCredFile($AzureUserName, $AzurePassword, $AzureTenantID, $AzureSubscriptionID, $DeploymentID, $azuserobjectid, $adminPassword, $SPDisplayName, $SPApplicationID, $SPSecretKey, $SPObjectID)
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/scripts/azurecreds.txt","C:\Packages\AzureCreds.txt")
    $WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/scripts/azurecreds.ps1","C:\Packages\AzureCreds.ps1")
    
    New-Item -ItemType directory -Path C:\LabFiles -force
    
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureUserObjectIDValue", "$azuserobjectid"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AdminPasswordValue", "$adminPassword"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "SPDisplayName", "$SPDisplayName"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "SPApplicationID", "$SPApplicationID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "SPSecretKey", "$SPSecretKey"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "SPObjectID", "$SPObjectID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"

         
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureUserObjectIDValue", "$azuserobjectid"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AdminPasswordValue", "$adminPassword"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPDisplayName", "$SPDisplayName"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPApplicationID", "$SPApplicationID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPSecretKey", "$SPSecretKey"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "SPObjectID", "$SPObjectID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"

    Copy-Item "C:\Packages\AzureCreds.txt" -Destination "C:\Users\Public\Desktop"
}

CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID $azuserobjectid $adminPassword $SPDisplayName $SPApplicationID $SPSecretKey $SPObjectID
. C:\Packages\AzureCreds.ps1

$userName = $AzureUserName
$password = $AzurePassword
$SubscriptionId = $AzureSubscriptionID
$vmPassword = $AdminPassword
        
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword
        
Connect-AzAccount -Credential $cred | Out-Null

#Download Main-Deployment Template
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/deploy-02.json", "C:\LabFiles\deploy-02.json")
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/deploy-02.parameters.json","C:\LabFiles\deploy-02.parameters.json")

(Get-Content -Path "C:\LabFiles\deploy-02.json") | ForEach-Object {$_ -Replace 'enter_objectid', $azuserobjectid} | Set-Content -Path "C:\LabFiles\deploy-02.json"
(Get-Content -Path "C:\LabFiles\deploy-02.parameters.json") | ForEach-Object {$_ -Replace 'enter_objectid', $azuserobjectid} | Set-Content -Path "C:\LabFiles\deploy-02.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-02.json") | ForEach-Object {$_ -Replace 'enter_deploymentid', $DeploymentID} | Set-Content -Path "C:\LabFiles\deploy-02.json"
(Get-Content -Path "C:\LabFiles\deploy-02.parameters.json") | ForEach-Object {$_ -Replace 'enter_deploymentid', $DeploymentID} | Set-Content -Path "C:\LabFiles\deploy-02.parameters.json"

sleep 60

#Deploy ARM-Template1
$rgName = (Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*smart-spaces*"}).ResourceGroupName
New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateUri "C:\LabFiles\deploy-02.json" -TemplateParameterUri "C:\LabFiles\deploy-02.parameters.json"

sleep 600

#Download Logon Task
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/many-models/smart-spaces-sustainability/scripts/psscript2.ps1","C:\LabFiles\psscript2.ps1")

#Enable Auto-Logon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$vmPassword" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

#checkdeployment
$status = (Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name "deploy-02").ProvisioningState
$status
if ($status -eq "Succeeded")
{
 
    $Validstatus="Pending"  ##Failed or Successful at the last step
    $Validmessage="Main Deployment is successful, logontask is pending"

# Scheduled Task
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\demouser"
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\LabFiles\psscript2.ps1"
Register-ScheduledTask -TaskName "Setup" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force
Set-ExecutionPolicy -ExecutionPolicy bypass -Force

}
else {
    Write-Warning "Validation Failed - see log output"
    $Validstatus="Failed"  ##Failed or Successful at the last step
    $Validmessage="ARM template Deployment Failed"
      }

Stop-Transcript
Restart-Computer -Force
