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
    $DeploymentID,
    
    [string]
    $adminUsername,
    
    [string]
    $adminPassword
)

Start-Transcript -Path C:\WindowsAzure\Logs\CustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#Download git repository
New-Item -ItemType directory -Path C:\AllFiles
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://codeload.github.com/MSUSSolutionAccelerators/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/zip/refs/heads/main","C:\AllFiles\AI-Call-Center.zip")

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
Expand-ZIPFile -File "C:\AllFiles\AI-Call-Center.zip" -Destination "C:\AllFiles\"

#Disable Enhanced Security for Internet Explorer
Function Disable-InternetExplorerESC
{
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force -ErrorAction SilentlyContinue -Verbose
    #Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green -Verbose
}

#Enable File Download on Windows Server Internet Explorer
Function Enable-IEFileDownload
{
    $HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    $HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    Set-ItemProperty -Path $HKLM -Name "1803" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1803" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKLM -Name "1604" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1604" -Value 0 -ErrorAction SilentlyContinue -Verbose
}

#Enable Copy Page Content in IE
Function Enable-CopyPageContent-In-InternetExplorer
{
    $HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    $HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
    Set-ItemProperty -Path $HKLM -Name "1407" -Value 0 -ErrorAction SilentlyContinue -Verbose
    Set-ItemProperty -Path $HKCU -Name "1407" -Value 0 -ErrorAction SilentlyContinue -Verbose
}

#Install Chocolatey
Function InstallChocolatey
{   
    #[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
    #[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
    $env:chocolateyUseWindowsCompression = 'true'
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -Verbose
    choco feature enable -n allowGlobalConfirmation
}

#Disable PopUp for network configuration
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

    #Disable Welcome page of Microsoft Edge:
    Set-Location hklm:
    Test-Path .\Software\Policies\Microsoft
    New-Item -Path .\Software\Policies\Microsoft -Name MicrosoftEdge
    New-Item -Path .\Software\Policies\Microsoft\MicrosoftEdge -Name Main
    New-ItemProperty -Path .\Software\Policies\Microsoft\MicrosoftEdge\Main -Name PreventFirstRunPage -Value "1" -Type DWORD -Force -ErrorAction SilentlyContinue | Out-Null
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
InstallEdgeChromium
}

# Run declared functions from psscript.ps1
WindowsServerCommon
InstallAzPowerShellModule
InstallChocolatey

#Create Cred File
Function CreateCredFile($AzureUserName, $AzurePassword, $AzureTenantID, $AzureSubscriptionID, $DeploymentID, $azuserobjectid, $adminPassword, $SPDisplayName, $SPApplicationID, $SPSecretKey, $SPObjectID)
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/scripts/AzureCreds.txt","C:\Packages\AzureCreds.txt")
    $WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/scripts/AzureCreds.ps1","C:\Packages\AzureCreds.ps1")
    
    New-Item -ItemType directory -Path C:\LabFiles -force
    
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AdminUsernameValue", "$adminUsername"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
    (Get-Content -Path "C:\Packages\AzureCreds.txt") | ForEach-Object {$_ -Replace "AdminPasswordValue", "$adminPassword"} | Set-Content -Path "C:\Packages\AzureCreds.txt"
       
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AdminUsernameValue", "$adminUsername"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
    (Get-Content -Path "C:\Packages\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AdminPasswordValue", "$adminPassword"} | Set-Content -Path "C:\Packages\AzureCreds.ps1"
  
    Copy-Item "C:\Packages\AzureCreds.txt" -Destination "C:\Users\Public\Desktop"
}

#Download power Bi desktop
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe","C:\LabFiles\PBIDesktop_x64.exe")

#Install power Bi desktop
Start-Process -FilePath "C:\LabFiles\PBIDesktop_x64.exe" -ArgumentList '-quiet','ACCEPT_EULA=1'
[Environment]::SetEnvironmentVariable("PBI_enableWebView2Preview","0", "Machine")

sleep 10

#Copy PowerBI file to the Desktop
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/MSUSSolutionAccelerators/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/main/powerbi/SpeechInsights.pbit","C:\LabFiles\SpeechInsights.pbit")
$WebClient.DownloadFile("https://raw.githubusercontent.com/MSUSSolutionAccelerators/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/main/powerbi/SentimentInsights.pbit","C:\LabFiles\SentimentInsights.pbit")

Copy-Item -Path C:\LabFiles\SpeechInsights.pbit -Destination C:\Users\public\Desktop -Force
Copy-Item -Path C:\LabFiles\SentimentInsights.pbit -Destination C:\Users\public\Desktop -Force

#Import creds
. C:\Packages\AzureCreds.ps1

$userName = $AzureUserName
$password = $AzurePassword
$vmUsername = $adminUsername
$vmPassword = $adminPassword
$deployID = $DeploymentID
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

#deploy armtemplate
Import-Module Az
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/templates/deploy-02.json","C:\LabFiles\deploy-02.json")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/templates/deploy-02.parameters.json","C:\LabFiles\deploy-02.parameters.json")

(Get-Content -Path "C:\LabFiles\deploy-02.json") | ForEach-Object {$_ -Replace "enter_deploymentid", "$deployID"} | Set-Content -Path "C:\LabFiles\deploy-02.json"
(Get-Content -Path "C:\LabFiles\deploy-02.parameters.json") | ForEach-Object {$_ -Replace "enter_deploymentid", "$deployID"} | Set-Content -Path "C:\LabFiles\deploy-02.parameters.json"

New-AzResourceGroupDeployment -ResourceGroupName "many-models-$DeploymentID" -TemplateUri  "C:\LabFiles\deploy-02.json" -TemplateParameterUri "C:\LabFiles\deploy-02.parameters.json" 

sleep 300

choco install dotnetcore-sdk

Function InstallNodeJS
{
    choco install nodejs -y -force
}
InstallNodeJS

Function InstallVSCode
{
    choco install vscode -y -force
}
InstallVSCode

Function InstallDotNet4.5
{
    choco install dotnet4.5 -y -force
}
InstallDotNet4.5

Function InstallDotNetFW4.8
{
    choco install dotnetfx -y -force
}
InstallDotNetFW4.8


#Download LogonTask
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/scripts/logon.ps1","C:\LabFiles\logon.ps1")

#Enable Auto-Logon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\$vmUsername" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$vmPassword" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

#Check Deployment
$status = (Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name "deploy-02").ProvisioningState
$status
if ($status -eq "Succeeded")
{
 
    $Validstatus="Pending"  ##Failed or Successful at the last step
    $Validmessage="Main Deployment is successful, logontask is pending"

# Scheduled Task
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\$vmUsername"
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File C:\LabFiles\logon.ps1"
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
