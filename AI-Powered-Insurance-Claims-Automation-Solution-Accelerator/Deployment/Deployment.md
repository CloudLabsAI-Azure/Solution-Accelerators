# Deployment Steps

1. Click on the **Deploy to Azure** button below, and log in to Azure portal using your credentials if you are prompted to do so.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FCloudLabsAI-Azure%2FSolution-Accelerators%2Fmain%2FAI-Powered-Insurance-Claims-Automation-Solution-Accelerator%2Ftemplates%2Fdeploy-01.json)

1. Make sure to select a subsription.
2. **Resource group**: click on create new and enter **fsihack**, then click on **ok**
3. provide the necessary details for the remaining fields   
     *  **Admin User Name**: demouser
     *  **Admin User Password** Provide a secure password
    *  **Azure User Name**: Enter your azure user name
    *  **Azure Password**: Enter your azure password
    *  **Deployment ID**: Enter unique number ( ex: 1541)
4. Click on **Review+Create** and once validation success click on **Create**.

<img width="371" alt="Screenshot_7" src="https://user-images.githubusercontent.com/33771500/196679524-afb034db-4eb2-402e-aba5-a99526cdea4c.png">

### Post-Deployment Verification:

## List of Artifacts Deployed
* API Connection
  * Azure Blob
* App Services
  * Blob operations
  * CosmosDb
  * Form Recognizer
  * Luis
  * Web API & Web App(UI)
* App Service Plan
* Application Insight
* Cognitive Services
  * All-in-one Cognitive Services
  * Custom Vision Training & Prediction
  * Form Recognizer
  * Luis Authoring
* Logic Apps
* Azure Search
* Storage Account
  * Storage for Forms
  * Storage for Training

## Congratulations
You have completed this solution accelerator.

