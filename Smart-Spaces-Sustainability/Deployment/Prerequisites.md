# Steps to take before Deploying

1. Create A Resource Group
    1. Navigate to resource groups in Azure, and click on **Create**
    2. Make sure to select a subscription, and provide the resource group name: "smart-spaces"
    3. Under resource details, select the dropdown for **Region**, and select any region you wish to deploy 

2. Retrieve Azure User ObjectID
    1. Within Azure resource group, open azure cli
    2. enter command: Get-AzADUser
    3. Copy the Object ID associated with the desired user to request the deployment.

3. Create A Service Principal
    1. Navigate to Azure Active Directory(AAD)> App Registrations, and click on **New registration**
    2. Make sure to provide a name to the app, and click **Register** to create the app
    3. Upon successfully creating the app, make sure to copy the **Display name, Application(client) ID, Object ID**, and store it in a notepad for reference:
    
    
       <img width="565" alt="image" src="https://user-images.githubusercontent.com/83011430/195068161-49589f52-b2d6-4e4d-808f-9b14cc90ad43.png">
    
    4. Navigate to *Certificates & secrets* under the same app you created earlier, click on **New client secret**, and provide a name for the secret, and click on     **Add**. Once the secret is created, make sure to copy the value, and store it in the same notepad used earlier since the value will not be available to copy after some time:
    
    
       <img width="778" alt="image" src="https://user-images.githubusercontent.com/83011430/195070565-84cd3aa7-bb0a-4b7b-9813-cba6c50d64f6.png">
