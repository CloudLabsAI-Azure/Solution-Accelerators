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


Function Disable-InternetExplorerESC
{
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force -ErrorAction SilentlyContinue -Verbose
    #Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green -Verbose
}

#Function2 - Enable File Download on Windows Server Internet Explorer
Function Enable-IEFileDownload
{
    $HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    $HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    Set-ItemProperty -Path $HKLM -Name "1803" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1803" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKLM -Name "1604" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1604" -Value 0 -ErrorAction SilentlyContinue -Verbose
}

#Function3 - Enable Copy Page Content in IE
Function Enable-CopyPageContent-In-InternetExplorer
{
    $HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    $HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    Set-ItemProperty -Path $HKLM -Name "1407" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1407" -Value 0 -ErrorAction SilentlyContinue -Verbose
}

#Function4 Install Chocolatey
Function InstallChocolatey
{   
    #[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
    #[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
    $env:chocolateyUseWindowsCompression = 'true'
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -Verbose
    choco feature enable -n allowGlobalConfirmation
}

#Function5 Disable PopUp for network configuration

Function DisableServerMgrNetworkPopup
{
    cd HKLM:\
    New-Item -Path HKLM:\System\CurrentControlSet\Control\Network -Name NewNetworkWindowOff -Force 

    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
}

Function CreateLabFilesDirectory
{
    New-Item -ItemType directory -Path C:\LabFiles -force
}

Function DisableWindowsFirewall
{
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

}

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

Function InstallEdgeChromium
{
    #Download and Install edge
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("http://go.microsoft.com/fwlink/?LinkID=2093437","C:\Packages\MicrosoftEdgeBetaEnterpriseX64.msi")
    sleep 5
    
    Start-Process msiexec.exe -Wait '/I C:\Packages\MicrosoftEdgeBetaEnterpriseX64.msi /qn' -Verbose 
    sleep 5
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Azure Portal.lnk")
    $Shortcut.TargetPath = """C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"""
    $argA = """https://portal.azure.com"""
    $Shortcut.Arguments = $argA 
    $Shortcut.Save()
}

Function InstallAzCLI
{
    choco install azure-cli -y -force
}

Function CreateCredFile($AzureUserName, $AzurePassword, $AzureTenantID, $AzureSubscriptionID, $DeploymentID)
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Azure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator/AzureCreds.txt","C:\LabFiles\AzureCreds.txt")
    $WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Azure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator/AzureCreds.ps1","C:\LabFiles\AzureCreds.ps1")
    
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

Function InstallVSCode
{

    choco install vscode -y -force

}

Function WindowsServerCommon
{
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
Disable-InternetExplorerESC
Enable-IEFileDownload
Enable-CopyPageContent-In-InternetExplorer
InstallChocolatey
DisableServerMgrNetworkPopup
CreateLabFilesDirectory
DisableWindowsFirewall
InstallAzPowerShellModule
InstallAzCLI
InstallEdgeChromium
InstallVSCode
}

WindowsServerCommon

CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID





#Download power Bi desktop

$WebClient = New-Object System.Net.WebClient



$WebClient.DownloadFile("https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe","C:\LabFiles\PBIDesktop_x64.exe")



#INstall power Bi desktop

Start-Process -FilePath "C:\LabFiles\PBIDesktop_x64.exe" -ArgumentList '-quiet','ACCEPT_EULA=1'

[Environment]::SetEnvironmentVariable("PBI_enableWebView2Preview","0", "Machine")



sleep 2
#Download storage explorer
choco install microsoftazurestorageexplorer

sleep 10

#Create shorcut in desktop
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\StorageExplorer.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft Azure Storage Explorer\StorageExplorer.exe"
$Shortcut.Save()

#Copy PowerBI file to the Desktop
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/microsoft/Azure-Synapse-Content-Recommendations-Solution-Accelerator/main/reports/ContentRecommendations.pbit","C:\LabFiles\ContentRecommendations.pbit")

Copy-Item -Path C:\LabFiles\ContentRecommendations.pbit -Destination C:\Users\public\Desktop -Force


#download datasets

New-Item -Path 'C:\MicrosoftNewsDataset' -ItemType Directory
New-Item -Path 'C:\MicrosoftNewsDataset\MINDlarge_test' -ItemType Directory
New-Item -Path 'C:\MicrosoftNewsDataset\MINDsmall_train' -ItemType Directory
New-Item -Path 'C:\MicrosoftNewsDataset\MINDsmall_dev' -ItemType Directory

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://mind201910small.blob.core.windows.net/release/MINDlarge_test.zip","C:\LabFiles\MINDlarge_test.zip")

Sleep 10

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
Expand-ZIPFile -File "C:\LabFiles\MINDlarge_test.zip" -Destination "C:\MicrosoftNewsDataset\MINDlarge_test\"


$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://mind201910small.blob.core.windows.net/release/MINDsmall_train.zip","C:\LabFiles\MINDsmall_train.zip")

Sleep 10

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
Expand-ZIPFile -File "C:\LabFiles\MINDsmall_train.zip" -Destination "C:\MicrosoftNewsDataset\MINDsmall_train\"


$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://mind201910small.blob.core.windows.net/release/MINDsmall_dev.zip","C:\LabFiles\MINDsmall_dev.zip")

Sleep 10

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
Expand-ZIPFile -File "C:\LabFiles\MINDsmall_dev.zip" -Destination "C:\MicrosoftNewsDataset\MINDsmall_dev\"




#Import creds
CD C:\LabFiles
$credsfilepath = ".\AzureCreds.txt"
$creds = Get-Content $credsfilepath | Out-String | ConvertFrom-StringData
$AzureUserName = "$($creds.AzureUserName)"
$AzurePassword = "$($creds.AzurePassword)"
$SubscriptionId = "$($creds.AzureSubscriptionID)"
$passwd = ConvertTo-SecureString $AzurePassword -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AzureUserName, $passwd



#deploy armtemplate

$Uniquestr= $DeploymentID.Substring(8)


$parm = "man"+$Uniquestr
Import-Module Az
Connect-AzAccount -Credential $cred
Select-AzSubscription -SubscriptionId $SubscriptionId
$rgName = (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "many*" }).ResourceGroupName
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Azure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator/azuredeploy.json", "C:\LabFiles\azuredeploy.json")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Azure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator/azuredeployparm.json","C:\LabFiles\azuredeployparm.json")


(Get-Content -Path "C:\LabFiles\azuredeployparm.json") | ForEach-Object {$_ -Replace 'abc', $parm} | Set-Content -Path "C:\LabFiles\azuredeployparm.json"

New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "C:\LabFiles\azuredeploy.json" -TemplateParameterFile "C:\LabFiles\azuredeployparm.json"


#storage copy
$userName = $AzureUserName
$password = $AzurePassword

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SpektraSystems/CloudLabs-Azure/master/azure-synapse-analytics-workshop-400/artifacts/setup/azcopy.exe" -OutFile "C:\labfiles\azcopy.exe"

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null


$storageAccounts = Get-AzResource -ResourceGroupName $rgName -ResourceType "Microsoft.Storage/storageAccounts"
$storageName = $storageAccounts | Where-Object { $_.Name -like 'ma*' }
$storage = Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageName.Name
$storageContext = $storage.Context

$srcUrl = $null
$rgLocation = (Get-AzResourceGroup -Name $rgName).Location
          

$srcUrl = "C:\MicrosoftNewsDataset"

           
$destContext = $storage.Context
$containerName = "cms"
$resources = $null

New-AzStorageContainer -Context $destContext -Name $containerName -ErrorAction Ignore

$startTime = Get-Date
$endTime = $startTime.AddDays(2)
$destSASToken = New-AzStorageContainerSASToken  -Context $destContext -Container "cms" -Permission rwd -StartTime $startTime -ExpiryTime $endTime
$destUrl = $destContext.BlobEndPoint + "cms" + $destSASToken

$srcUrl 
$destUrl

C:\LabFiles\azcopy.exe copy $srcUrl $destUrl --recursive

#download notebooks
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Azure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator/01-Load-Data.ipynb","C:\LabFiles\01-Load-Data.ipynb")
$WebClient.DownloadFile("https://raw.githubusercontent.com/microsoft/Azure-Synapse-Content-Recommendations-Solution-Accelerator/main/src/02-Train-Model.ipynb","C:\LabFiles\02-Train-Model.ipynb")
$WebClient.DownloadFile("https://raw.githubusercontent.com/microsoft/Azure-Synapse-Content-Recommendations-Solution-Accelerator/main/src/03-Recommendations.ipynb","C:\LabFiles\03-Recommendations.ipynb")

#Download LogonTask
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Azure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator/logon.ps1","C:\LabFiles\logon.ps1")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/Azure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator/Pipeline%201.json","C:\LabFiles\Pipeline 1.json")




#Enable Auto-Logon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "Password.1!!" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord



# Scheduled Task
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\demouser"
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\LabFiles\logon.ps1"
Register-ScheduledTask -TaskName "Setup" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force
Set-ExecutionPolicy -ExecutionPolicy bypass -Force
