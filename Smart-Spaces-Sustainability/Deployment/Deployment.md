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

1. Open the POSTMan DESKTOP Tool : https://www.postman.com/
2. Navigate to your installation of the Azure Function App named: FuncSMARTSPACE-HVAC
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
