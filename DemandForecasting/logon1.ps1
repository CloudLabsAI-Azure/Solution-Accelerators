Start-Transcript -Path C:\WindowsAzure\Logs\logon.txt -Append


python -m pip install --upgrade pip
pip install azureml-opendatasets
pip install azureml-core --force
pip install "ipython<5"
pip install --upgrade azureml-sdk
pip install azureml-contrib-automl-pipeline-steps
pip install --upgrade azureml-train-automl
pip install azureml.contrib.automl.pipeline.steps


cd C:\LabFiles





. C:\LabFiles\AzureCreds.ps1

#storage copy
$userName = $AzureUserName
$password = $AzurePassword
$SubscriptionId = $AzureSubscriptionID



[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SpektraSystems/CloudLabs-Azure/master/azure-synapse-analytics-workshop-400/artifacts/setup/azcopy.exe" -OutFile "C:\labfiles\azcopy.exe"

$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

$rgName = (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "solution*" }).ResourceGroupName
$storageAccounts = Get-AzResource -ResourceGroupName $rgName -ResourceType "Microsoft.Storage/storageAccounts"
$storageName = $storageAccounts | Where-Object { $_.Name -like 'solution*' }
$storage = Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageName.Name
$storageContext = $storage.Context

$srcUrl = $null
$rgLocation = (Get-AzResourceGroup -Name $rgName).Location
          

$srcUrl = "https://experienceazure.blob.core.windows.net/azureml?sp=racwdli&st=2022-06-30T12:10:16Z&se=2025-05-31T20:10:16Z&sv=2021-06-08&sr=c&sig=lfHvC9%2FB5kt05q7MpeJmwnzrGYAYqmLOA0FR8B9v%2Fi0%3D"

           
$destContext = $storage.Context

#fetching the container in storage account
$strname="solution"+$DeploymentID
$Keys=(Get-AzStorageAccountKey -ResourceGroupName $rgName -Name $strname)| Where-Object {$_.KeyName -eq "key1"}
$key=$keys.value
$context = New-AzStorageContext -StorageAccountName $Strname -StorageAccountKey $key
$strcontext=Get-AzStorageContainer -Name azureml-* -Context $context
$containername=$strcontext.name


$resources = $null


$startTime = Get-Date
$endTime = $startTime.AddDays(2)
$destSASToken = New-AzStorageContainerSASToken  -Context $destContext -Container $containername -Permission rwd -StartTime $startTime -ExpiryTime $endTime
$destUrl = $destContext.BlobEndPoint + $containername + $destSASToken

$srcUrl 
$destUrl

C:\LabFiles\azcopy.exe copy $srcUrl $destUrl --recursive


#azure login
$SubscriptionId = $AzureSubscriptionID
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword
Connect-AzAccount -Credential $cred | Out-Null



$wsname="aml-solution-"+$DeploymentID
(Get-Content -Path "C:\LabFiles\demo1.py") | ForEach-Object {$_ -Replace "abc", "$wsname"} | Set-Content -Path "C:\LabFiles\demo1.py"
(Get-Content -Path "C:\LabFiles\demo1.py") | ForEach-Object {$_ -Replace "defg", "$SubscriptionId"} | Set-Content -Path "C:\LabFiles\demo1.py"
(Get-Content -Path "C:\LabFiles\demo1.py") | ForEach-Object {$_ -Replace "hij", "$rgname"} | Set-Content -Path "C:\LabFiles\demo1.py"
(Get-Content -Path "C:\LabFiles\demo2.py") | ForEach-Object {$_ -Replace "abc", "$wsname"} | Set-Content -Path "C:\LabFiles\demo2.py"
(Get-Content -Path "C:\LabFiles\demo2.py") | ForEach-Object {$_ -Replace "defg", "$SubscriptionId"} | Set-Content -Path "C:\LabFiles\demo2.py"
(Get-Content -Path "C:\LabFiles\demo2.py") | ForEach-Object {$_ -Replace "hij", "$rgname"} | Set-Content -Path "C:\LabFiles\demo2.py"





Python demo1.py
Python demo2.py

(Get-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\script3.py") | ForEach-Object {$_ -Replace "abc", "$wsname"} | Set-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\script3.py"
(Get-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\script3.py") | ForEach-Object {$_ -Replace "defg", "$SubscriptionId"} | Set-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\script3.py"
(Get-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\script3.py") | ForEach-Object {$_ -Replace "hij", "$rgname"} | Set-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\script3.py"
(Get-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\script4.py") | ForEach-Object {$_ -Replace "abc", "$wsname"} | Set-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\script4.py"
(Get-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\script4.py") | ForEach-Object {$_ -Replace "defg", "$SubscriptionId"} | Set-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\script4.py"
(Get-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\script4.py") | ForEach-Object {$_ -Replace "hij", "$rgname"} | Set-Content -Path "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\script4.py"




cd C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline

python script3.py


$Path = "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\02_AutoML_Training_Pipeline\runid.txt"
$values = Get-Content $Path | Out-String | ConvertFrom-StringData
$runid=$values.a

cd C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline

python script4.py $runid
