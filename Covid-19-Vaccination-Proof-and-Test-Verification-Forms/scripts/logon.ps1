Start-Transcript -Path C:\WindowsAzure\Logs\logon.txt -Append

#InstallAzmodule
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -Installationpolicy Trusted
Install-Module -Name Az.Synapse -Force
Import-Module -Name Az.Synapse

. C:\LabFiles\AzureCreds.ps1

$userName = $AzureUserName # READ FROM FILE
$password = $AzurePassword # READ FROM FILE
$Sid = $AzureSubscriptionID # READ FROM FILE
$deployId = $DeploymentID


$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

$rgName = (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "many*" }).ResourceGroupName

$storageAccounts = Get-AzResource -ResourceGroupName $rgName -ResourceType "Microsoft.Storage/storageAccounts"
$storageName = $storageAccounts | Where-Object { $_.Name -like 'syn*' }
$storageaccountname = $storageName.Name


$synapseworkspace = Get-AzResource -ResourceGroupName $rgName -ResourceType "Microsoft.Synapse/workspaces"
$synapse1 = $synapseworkspace | Where-Object { $_.Name -like 'syn*' }
$synapse = $synapse1.Name

#adding roles
$id3 = $userName
New-AzRoleAssignment -SignInName $id3 -RoleDefinitionName "Storage Blob Data Contributor" -Scope "/subscriptions/$Sid/resourceGroups/$rgName/providers/Microsoft.Storage/storageAccounts/$storageaccountname"

#Adding IP
New-AzSynapseFirewallRule -WorkspaceName $synapse -Name all -StartIpAddress "0.0.0.0" -EndIpAddress "255.255.255.255"
sleep 20
