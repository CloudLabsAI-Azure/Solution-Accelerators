CLS
az login -u "enter_uname" -p "enter_password"
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#$ STEP 3 = IOTHub CLI Deployment SCRIPT
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#$ (1)  Initializes IOTHub Device Twin Properties for (4) Devices.
#$ (2)  Retrieves IOTHub Connection Strings
#$ (3)  Retrieves IOTHub Device Connection Strings
#$ (4)  SET Key Vault Secrets
#$ (5)  GET URI's of Key Vault Secrets
#  (6)  SET Key Vault URI Variabless
#  (7)  CREATE / UPDATE FUNCTION APP SETTINGS:
#  (8)  Get Function App Principal ID + App Id
#  (9)  Set Key Vault Access Policy - so can be read from Azure Function App
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
####################################################
# Set the variables below to match your Azure Environment
####################################################
$IOTHubName = 'enter_iothubname'
$RGP = 'enter_rgname'
$KVName = "enter_kvname"
$FuncHVACName = "enter_funchvacname"
$FuncSmartSpaceName = "enter_funcsmartspacename"

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# Do Not modify below
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

#---
az config set extension.use_dynamic_install=yes_without_prompt
#---

#---
$newDeviceID = "smartspace-iotdevice" # New DeviceID
#---
# Set Digital Twin Properties:
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/TEMP_UNITS\", \"value\": \"F\"}' 
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/SETPOINT\", \"value\": \"67\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CURRTEMP\", \"value\": \"67\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/LASTUPDT\", \"value\": \"2022-05-12 16:52:16.5\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CHILL_RATE\", \"value\": \"-1.5\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/RUN_STATE\", \"value\": \"Stopped\"}'

#---
$newDeviceID = "smartspace-hvac01-iotdevice" # New DeviceID
#---
# Set Digital Twin Properties:
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/TEMP_UNITS\", \"value\": \"F\"}' 
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/LASTUPDT\", \"value\": \"2022-05-12 16:52:16.5\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CHILL_RATE\", \"value\": \"-2.0\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CURRTEMP\", \"value\": \"63\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/REALPOWER\", \"value\": \"0\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/REALPOWER_RATE\", \"value\": \"3500\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/RUN_STATE\", \"value\": \"Running\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_SETPOINT\", \"value\": \"45\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_TEMP_ENTER\", \"value\": \"66\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_TEMP_LEAVE\", \"value\": \"63\"}'

#---
$newDeviceID = "smartspace-hvac02-iotdevice" # New DeviceID
#---
# Set Digital Twin Properties:
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/TEMP_UNITS\", \"value\": \"F\"}' 
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/LASTUPDT\", \"value\": \"2022-05-12 16:52:16.5\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CHILL_RATE\", \"value\": \"-2.0\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CURRTEMP\", \"value\": \"63\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/REALPOWER\", \"value\": \"0\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/REALPOWER_RATE\", \"value\": \"3500\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/RUN_STATE\", \"value\": \"Running\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_SETPOINT\", \"value\": \"45\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_TEMP_ENTER\", \"value\": \"66\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_TEMP_LEAVE\", \"value\": \"63\"}'

#---
$newDeviceID = "smartspace-hvac03-iotdevice" # New DeviceID
#---
# Set Digital Twin Properties:
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/TEMP_UNITS\", \"value\": \"F\"}' 
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/LASTUPDT\", \"value\": \"2022-05-12 16:52:16.5\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CHILL_RATE\", \"value\": \"-2.0\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/CURRTEMP\", \"value\": \"63\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/REALPOWER\", \"value\": \"0\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/REALPOWER_RATE\", \"value\": \"3500\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/RUN_STATE\", \"value\": \"Running\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_SETPOINT\", \"value\": \"45\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_TEMP_ENTER\", \"value\": \"66\"}'
az iot hub digital-twin update --hub-name $IoTHubName --device-id $newDeviceID --json-patch '{\"op\":\"add\", \"path\":\"/H2O_TEMP_LEAVE\", \"value\": \"63\"}'

######################################
# Retrieve IOTHub Connection Strings
# Retrieve IOTHub Device Connection Strings
######################################
$IOTHubConnStr = az iot hub connection-string show --resource-group $RGP -n $IOTHubName --policy-name iothubowner --key-type primary --query "connectionString"

$IOTHubDevSmartSpaceHVAC01ConnStr = az iot hub device-identity connection-string show --resource-group $RGP --device-id 'smartspace-hvac01-iotdevice' --hub-name $IOTHubName --key-type primary --query "connectionString"
$IOTHubDevSmartSpaceHVAC02ConnStr = az iot hub device-identity connection-string show --resource-group $RGP --device-id 'smartspace-hvac02-iotdevice' --hub-name $IOTHubName --key-type primary --query "connectionString"
$IOTHubDevSmartSpaceHVAC03ConnStr = az iot hub device-identity connection-string show --resource-group $RGP --device-id 'smartspace-hvac03-iotdevice' --hub-name $IOTHubName --key-type primary --query "connectionString"

$IOTHubDevSmartSpaceConnStr = az iot hub device-identity connection-string show --resource-group $RGP --device-id 'smartspace-iotdevice' --hub-name $IOTHubName --key-type primary --query "connectionString"
$IOTHubDevSmartSpaceDeviceTwinConnStr = az iot hub device-identity connection-string show --resource-group $RGP --device-id 'smartspace-iotdevice' --hub-name $IOTHubName --key-type primary --query "connectionString"

###################################
#SET KV Secrets
###################################
az keyvault secret set --vault-name $KVName --name "iotHubConnectionStringDevice" --value "$IOTHubDevSmartSpaceConnStr"
az keyvault secret set --vault-name $KVName --name "iotHubConnectionStringDeviceTwin" --value "$IOTHubConnStr"

az keyvault secret set --vault-name $KVName --name "smart-space-hvac01-iotdevice-connstr" --value "$IOTHubDevSmartSpaceHVAC01ConnStr"
az keyvault secret set --vault-name $KVName --name "smart-space-hvac01-iotdevice-twin-connstr" --value "$IOTHubConnStr"

az keyvault secret set --vault-name $KVName --name "smart-space-hvac02-iotdevice-connstr" --value "$IOTHubDevSmartSpaceHVAC02ConnStr"
az keyvault secret set --vault-name $KVName --name "smart-space-hvac02-iotdevice-twin-connstr" --value "$IOTHubConnStr"

az keyvault secret set --vault-name $KVName --name "smart-space-hvac03-iotdevice-connstr" --value "$IOTHubDevSmartSpaceHVAC02ConnStr"
az keyvault secret set --vault-name $KVName --name "smart-space-hvac03-iotdevice-twin-connstr" --value "$IOTHubConnStr"

az keyvault secret set --vault-name $KVName --name "smart-space-iotdevice-connstr" --value "$IOTHubDevSmartSpaceConnStr"
az keyvault secret set --vault-name $KVName --name "smartspace-iotdevice-twin-connstr" --value "$IOTHubConnStr"

###################################
# GET URI's of KV Secrets
###################################
$hvac01connstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smart-space-hvac01-iotdevice-connstr").id
$hvac01devtwinconnstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smart-space-hvac01-iotdevice-twin-connstr").id

$hvac02connstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smart-space-hvac02-iotdevice-connstr").id
$hvac02devtwinconnstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smart-space-hvac02-iotdevice-twin-connstr").id

$hvac03connstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smart-space-hvac03-iotdevice-connstr").id
$hvac03devtwinconnstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smart-space-hvac03-iotdevice-twin-connstr").id

$smartspaceconnstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smart-space-iotdevice-connstr").id
$smartspacedevtwinconnstrURI = (Get-AzKeyVaultSecret -VaultName $KVName -Name "smartspace-iotdevice-twin-connstr").id

######################################
# SET KV URI Vars
######################################
$KVRef = "@Microsoft.KeyVault(SecretUri="

$KVhvac01connstrURI = ($KVRef+$hvac01connstrURI)
$KVhvac01devtwinconnstrURI = ($KVRef+$hvac01devtwinconnstrURI)

$KVhvac02connstrURI = ($KVRef+$hvac02connstrURI)
$KVhvac02devtwinconnstrURI = ($KVRef+$hvac02devtwinconnstrURI)

$KVhvac03connstrURI = ($KVRef+$hvac03connstrURI)
$KVhvac03devtwinconnstrURI = ($KVRef+$hvac03devtwinconnstrURI)

$KVsmartspaceconnstrURI = ($KVRef+$smartspaceconnstrURI)
$KVsmartspacedevtwinconnstrURI = ($KVRef+$smartspacedevtwinconnstrURI)

######################################
# UPDATE FUNCTION APP SETTINGS:
######################################

# SMARTSPACE-HVAC
az functionapp config appsettings set --name $FuncHVACName --resource-group $RGP --settings ("conn_smart_space_hvac01 = "+$KVhvac01connstrURI+')')
az functionapp config appsettings set --name $FuncHVACName --resource-group $RGP --settings ("conn_smart_space_hvac01_DeviceTwin = "+$KVhvac01devtwinconnstrURI+')')

az functionapp config appsettings set --name $FuncHVACName --resource-group $RGP --settings ("conn_smart_space_hvac02 = "+$KVhvac02connstrURI+')')
az functionapp config appsettings set --name $FuncHVACName --resource-group $RGP --settings ("conn_smart_space_hvac02_DeviceTwin = "+$KVhvac02devtwinconnstrURI+')')

az functionapp config appsettings set --name $FuncHVACName --resource-group $RGP --settings ("conn_smart_space_hvac03 = "+$KVhvac03connstrURI+')')
az functionapp config appsettings set --name $FuncHVACName --resource-group $RGP --settings ("conn_smart_space_hvac03_DeviceTwin = "+$KVhvac03devtwinconnstrURI+')')

# SMARTSPACE
az functionapp config appsettings set --name $FuncSmartSpaceName --resource-group $RGP --settings ("iotHubConnectionStringDevice = "+$KVsmartspaceconnstrURI+')')
az functionapp config appsettings set --name $FuncSmartSpaceName --resource-group $RGP --settings ("iotHubConnectionStringDeviceTwin = "+$KVsmartspacedevtwinconnstrURI+')')

az functionapp config appsettings set --name $FuncSmartSpaceName --resource-group $RGP --settings ("conn_smart_space = "+$KVsmartspaceconnstrURI+')')
az functionapp config appsettings set --name $FuncSmartSpaceName --resource-group $RGP --settings ("conn_smart_space_DeviceTwin = "+$KVsmartspacedevtwinconnstrURI+')')


#########################################
# Get Function App Principal ID + App Id
# Set KV Access Policy - so can read from Azr Function
#########################################
$hvacprin =  az functionapp identity show --name $FuncHVACName --resource-group $RGP --query "principalId"  
$hvacprinappid = (az ad sp show --id $hvacprin --query "appId")
az role assignment create --assignee-object-id $hvacprin --assignee-principal-type "ServicePrincipal" --role "Contributor" --resource-group $RGP
az role assignment create --assignee-object-id $hvacprin --assignee-principal-type "ServicePrincipal" --role "Key Vault Contributor" --resource-group $RGP
az keyvault set-policy --name $KVName --spn $hvacprinappid  --secret-permissions get

$smartspaceprin =  az functionapp identity show --name $FuncSmartSpaceName --resource-group $RGP --query "principalId"  
$smartspaceprinappid = (az ad sp show --id $smartspaceprin --query "appId")
az role assignment create --assignee-object-id $smartspaceprin --assignee-principal-type "ServicePrincipal" --role "Contributor" --resource-group $RGP
az role assignment create --assignee-object-id $smartspaceprin --assignee-principal-type "ServicePrincipal" --role "Key Vault Contributor" --resource-group $RGP
az keyvault set-policy --name $KVName --spn $smartspaceprinappid  --secret-permissions get

