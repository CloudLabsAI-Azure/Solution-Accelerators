# Deployment Steps

### Step 0 - Gather Pre-requisites:
Be sure to follow the pre-requisites guidance in the this document: [Prerequisites.md](https://github.com/CloudLabsAI-Azure/Solution-Accelerators/blob/main/Smart-Spaces-Sustainability/Deployment/Prerequisites.md)

When you are ready to DEPLOY - Click on the **Deploy to Azure** button:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FCloudLabsAI-Azure%2FSolution-Accelerators%2Fmain%2FSmart-Spaces-Sustainability%2Ftemplates%2Fdeploy-01.json)

Below is a sample view of the initial Azure deployment screen and the parameter values required:

1. Make sure to select a subsription
2. Select the resource group created earlier
3. And provide the necessary details for the remaining fields( including the service principal details copied earlier in a notepad)

   <img width="368" alt="image" src="https://user-images.githubusercontent.com/83011430/195091911-12a3e24e-6d01-4ef3-a25f-2c476481518e.png">
   
### Post-Deployment Verification:

To confirm a successful deployment, perform the following Steps:

##### Confirm Azure Functions - HTTP REST Operations:
This step will confirm the IOTHub deployment and coresponding simulation functionality.

1. Open the POSTMan DESKTOP Tool.
2. Navigate to your installation of the Azure Function App named: FuncSMARTSPACE-HVAC.
3. On the left-hand navigation menu, click on the "Functions" icon.
4. Click on the NAME of the deployed function. It should be named "FuncSMARTSPACE-HVAC".
5. Once loaded, Click on the "Get Function Url" icon.
6. Click on the "Copy to clipboard" LINK.  
7. PASTE the Azure Function URL into the POSTMan tool URL address bar.
8. Select "POST" as the HTTP Operation.
9. Enter the following JSON string as the RAW BODY Contents:
          {"DeviceID":"smartspace-HVAC01-iotdevice"}
10. Click "SEND" in the POSTMan tool and wait for a response. 

A successful HTTP reponse message would be "200 OK".

#### Triggering Logic App
This step will allow you to control when and for how long - the Azure Stream Analytics service is running.

There are two specific Logic Apps which you want to trigger namely: 

        * LogicApp-ASA-START-...

        * LogicApp-ASA-STOP-...

Best practice guidance would be to run the START Logic App every Hour. 
Then trigger the STOP Logic App to run every Hour - BUT FIVE MINUTES After the START Logic App has been triggered.

##### Confirm Azure SQL Database Table population:
This step will confirm the "back-end" deployment, the "front-end" IOTHub deployment, and all the corresponding simulation functionality.

1. Download/Open the SQL Server Management Studio (SSMS) Tool: https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16 
2. ConnectT to your newly installed Azure SQL Server Database instance:

        Server Type: Database Engine
        Server Name: <Your SQL Server Name>.database.windows.net
        Authentication: SQL Server Authentication
        Login:      <Your SQL User Name>
        > Can be retrieved by navigating to SQL Server resource provisioned in Azure > Server admin
        Password:   <Your SQL User Password>
        > Can be retrieved by navigating to Key Vault > Secrets > sqlpwd
        > Select the current version, scroll down and click on show Secret Value. Copy the secret value and enter it as the password.
   
   <img width="486" alt="image" src="https://user-images.githubusercontent.com/83011430/195109351-7593e544-23e4-4c98-a98e-104c877939e9.png">
   
3. RIGHT-CLICK on the table: [dbo].[HVACUnitIntermediate] and select "Select top 1000 rows".
4. A new Query window will open and display the query results. 
5. You may wish to add the following SQL to the end of the query to see the most current records: ORDER BY [DateTimeUTC] DESC

A successful deployment will display newly added records to the Azure SQL table -> [dbo].[HVACUnitIntermediate]

### CONGRATULATIONS! 

You have now successfully provisioned and configured the Solution Accelerator!
