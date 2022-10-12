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
    $DeploymentID
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

New-Item -ItemType directory -Path C:\AllFiles
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://codeload.github.com/microsoft/solution-accelerator-many-models/zip/refs/heads/master","C:\AllFiles\AllFiles.zip")
#unziping folder
function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item)
}
}
Expand-ZIPFile -File "C:\AllFiles\AllFiles.zip" -Destination "C:\AllFiles\"


##Creating the cred file for logon task

Function CreateCredFile($AzureUserName, $AzurePassword, $AzureTenantID, $AzureSubscriptionID, $DeploymentID)
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/AzureCreds.txt","C:\LabFiles\AzureCreds.txt")
    $WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/AzureCreds.ps1","C:\LabFiles\AzureCreds.ps1")
    
    New-Item -ItemType directory -Path C:\LabFiles -force

    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
             
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"

    Copy-Item "C:\LabFiles\AzureCreds.txt" -Destination "C:\Users\Public\Desktop"
}

CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID




##Install AZ Powershell  module

Function InstallAzPowerShellModule
{
    <#Install-PackageProvider NuGet -Force
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module Az -Repository PSGallery -Force -AllowClobber#>

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://github.com/Azure/azure-powershell/releases/download/v5.0.0-October2020/Az-Cmdlets-5.0.0.33612-x64.msi","C:\Packages\Az-Cmdlets-5.0.0.33612-x64.msi")
    sleep 5
    Start-Process msiexec.exe -Wait '/I C:\Packages\Az-Cmdlets-5.0.0.33612-x64.msi /qn' -Verbose 

}

InstallAzPowerShellModule



##Install Visual studio code

Function InstallChocolatey
{   
    #[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
    #[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
    $env:chocolateyUseWindowsCompression = 'true'
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -Verbose
    choco feature enable -n allowGlobalConfirmation
}

InstallChocolatey

Function InstallVSCode
{

    choco install vscode -y -force

}

InstallVSCode



#Login to Azure
$securePassword = $AzurePassword | ConvertTo-SecureString -AsPlainText -Force
$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $AzureUserName, $SecurePassword
Connect-AzAccount -Credential $creds


#Storage Copy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SpektraSystems/CloudLabs-Azure/master/azure-synapse-analytics-workshop-400/artifacts/setup/azcopy.exe" -OutFile "C:\labfiles\azcopy.exe"


$resourceGroupName = (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "so*" }).ResourceGroupName
$storageAccounts = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Storage/storageAccounts"



$storageName = $storageAccounts | Where-Object { $_.Name -like 'so*' }
$mlstorageAccName = $storageName.Name
$ctx=(Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $mlstorageAccName).Context
$fileShares=Get-AZStorageShare -Context $ctx
$fileShare= ($fileShares | Where-Object { $_.Name -like 'code-*' }).Name





$srcUrl = "C:\AllFiles\solution-accelerator-many-models-master"



$destContext=$ctx



$startTime = Get-Date
$endTime = $startTime.AddDays(6)
$destSASToken=New-AzStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -Context $destContext -StartTime $startTime -ExpiryTime $endTime
$destUrl = "https://$mlstorageAccName.file.core.windows.net/" + $fileShare + "/Users/odl_user" + $destSASToken




$srcUrl
$destUrl
C:\LabFiles\azcopy.exe copy $srcUrl $destUrl --recursive

choco install python --version=3.6.7 --force
choco install azurepowershell --force

choco install az.powershell --force

choco install azure-cli

#downloading pythonfiles
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/DemandForecasting/pythonscript/demo1.py","C:\LabFiles\demo1.py")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/DemandForecasting/pythonscript/demo2.py","C:\LabFiles\demo2.py")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/DemandForecasting/pythonscript/demo4.py","C:\LabFiles\demo4.py")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/DemandForecasting/pythonscript/script3.py","C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\script3.py")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/DemandForecasting/pythonscript/script4.py","C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\script4.py")


#Download LogonTask
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/DemandForecasting/logon1.ps1","C:\LabFiles\logon1.ps1")



#Enable Auto-Logon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "Password.1!!" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord



# Scheduled Task
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\demouser"
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\LabFiles\logon1.ps1"
Register-ScheduledTask -TaskName "Setup" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force
Set-ExecutionPolicy -ExecutionPolicy bypass -Force
