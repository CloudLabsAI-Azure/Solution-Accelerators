Start-Transcript -Path C:\WindowsAzure\Logs\Logon.txt -Append
 . C:\LabFiles\AzureCreds.ps1

$userName = $AzureUserName # READ FROM FILE
$password = $AzurePassword # READ FROM FILE
$Sid = $AzureSubscriptionID # READ FROM FILE
$deployId = $DeploymentID

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

$RG=Get-AzResourceGroup 
$RGName=$RG.ResourceGroupName
$RGLoc=$RG.Location
$str = "callstorage"+$DeploymentID
                             
$keys=Get-AzCognitiveServicesAccountKey -ResourceGroupName $RGName -Name speech$deployId
$key1=$keys.key1
$textkeys=Get-AzCognitiveServicesAccountKey -ResourceGroupName $RGName -Name textanalytics$deployId
$key=$textKeys.key1

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/templates/deploy-03.json","C:\LabFiles\deploy-03.json")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/templates/deploy-03.parameters.json","C:\LabFiles\deploy-03.parameters.json")

dotnet new console
dotnet add package Microsoft.CognitiveServices.Speech --version 1.22.0
dotnet add package Microsoft.CognitiveServices.Speech

Copy-Item -Path C:\Windows\System32\system32.csproj -Destination C:\Users\demouser
copy-Item -Path C:\Windows\System32\Program.cs -Destination C:\Users\demouser

Remove-Item -Path C:\Users\demouser\Program.cs

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/scripts/Program1.cs","C:\Users\demouser\Program1.cs")

(Get-Content -Path "C:\Users\demouser\Program1.cs") | ForEach-Object {$_ -Replace "<speechkey>", "$key1"} | Set-Content -Path "C:\Users\demouser\Program1.cs"
(Get-Content -Path "C:\Users\demouser\Program1.cs") | ForEach-Object {$_ -Replace "<azregion>", "$RGLoc"} | Set-Content -Path "C:\Users\demouser\Program1.cs"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace "azregion", "$RGLoc"} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace "dpid", "$deployId"} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace "speechkey", "$key1"} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\LabFiles\deploy-03.parameters.json") | ForEach-Object {$_ -Replace "azaccount", "$str"} | Set-Content -Path "C:\LabFiles\deploy-03.parameters.json"
(Get-Content -Path "C:\AllFiles\AI-Powered-Call-Center-Intelligence-Solution-Accelerator-main\azure-speech-streaming-reactjs\speechexpressbackend\.env") | ForEach-Object {$_ -Replace "speechkey", "$key1"} | Set-Content -Path "C:\AllFiles\AI-Powered-Call-Center-Intelligence-Solution-Accelerator-main\azure-speech-streaming-reactjs\speechexpressbackend\.env"
(Get-Content -Path "C:\AllFiles\AI-Powered-Call-Center-Intelligence-Solution-Accelerator-main\azure-speech-streaming-reactjs\speechexpressbackend\.env") | ForEach-Object {$_ -Replace "centralus", "$RGLoc"} | Set-Content -Path "C:\AllFiles\AI-Powered-Call-Center-Intelligence-Solution-Accelerator-main\azure-speech-streaming-reactjs\speechexpressbackend\.env"
(Get-Content -Path "C:\AllFiles\AI-Powered-Call-Center-Intelligence-Solution-Accelerator-main\azure-speech-streaming-reactjs\speechexpressbackend\.env") | ForEach-Object {$_ -Replace "testapikey", "$key"} | Set-Content -Path "C:\AllFiles\AI-Powered-Call-Center-Intelligence-Solution-Accelerator-main\azure-speech-streaming-reactjs\speechexpressbackend\.env"


#deploy armtemplate

Import-Module Az
Connect-AzAccount -Credential $cred
Select-AzSubscription -SubscriptionId $AzureSubscriptionID
New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile C:\LabFiles\deploy-03.json -TemplateParameterFile C:\LabFiles\deploy-03.parameters.json

#storage copy
$userName = $AzureUserName
$password = $AzurePassword

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/artifacts/azcopy.exe" -OutFile "C:\labfiles\azcopy.exe"

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

$rgName = (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "many*" }).ResourceGroupName
$storageAccounts = Get-AzResource -ResourceGroupName $rgName -ResourceType "Microsoft.Storage/storageAccounts"
$storageName = $storageAccounts | Where-Object { $_.Name -like 'call*' }
$storage = Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageName.Name
$storageContext = $storage.Context

$srcUrl = $null
$rgLocation = (Get-AzResourceGroup -Name $rgName).Location
          
New-Item -Path 'C:\audio-input' -ItemType Directory

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/artifacts/azure-custom-speech_sampledata_test_audio.wav","C:\audio-input\azure-custom-speech_sampledata_test_audio.wav")
$WebClient.DownloadFile("https://raw.githubusercontent.com/CloudLabsAI-Azure/Solution-Accelerators/main/AI-Powered-Call-Center-Intelligence-Solution-Accelerator/artifacts/call-batch-analytics_sampledata_SampleData-SiriAzureGoogleTalk1.wav","C:\audio-input\call-batch-analytics_sampledata_SampleData-SiriAzureGoogleTalk1.wav")

$srcUrl = "C:\audio-input"          
$destContext = $storage.Context
$containerName = "audio-input"
$resources = $null

$startTime = Get-Date
$endTime = $startTime.AddDays(20)
$destSASToken = New-AzStorageContainerSASToken  -Context $destContext -Container "audio-input" -Permission rwd -StartTime $startTime -ExpiryTime $endTime
$destUrl = $destContext.BlobEndPoint + "audio-input" + $destSASToken

$srcUrl 
$destUrl

C:\LabFiles\azcopy.exe copy $srcUrl $destUrl --recursive

Stop-Transcript
Restart-Computer -Force
