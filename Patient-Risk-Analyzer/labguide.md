
![](https://github.com/CloudLabsAI-Azure/Machine-Learning-Patient-Risk-Analyzer-SA/raw/main/Resource_Deployment/img/banner.png)

# About this repository 
Machine Learning Patient Risk Analyzer Solution Accelerator is an end-to-end (E2E) healthcare app that leverages ML prediction models (e.g., Diabetes Mellitus (DM) patient 30-day re-admission, breast cancer risk, etc.) to demonstrate how these models can provide key insights for both physicians and patients.  Patients can easily access their appointment and care history with infused cognitive services through a conversational interface.  
  
In addition to providing new insights for both doctors and patients, the app also provides the Data Scientist/IT Specialist with one-click experiences for registering and deploying a new or existing model to Azure Kubernetes Clusters, and best practices for maintaining these models through Azure MLOps.

## Architecture Overview 
The architecture diagram below details what you will be building for this Solution Accelerator.

![Architecture Diagram](https://github.com/CloudLabsAI-Azure/Machine-Learning-Patient-Risk-Analyzer-SA/blob/main/Resource_Deployment/img/ReferenceArchitecture.png?raw=true)

## Azure Development and Analytics Platforms 
The directions provided for this repository assume fundemental working knowledge of Azure, Azure Synapse Analytics, Azure Machine Learning and Azure Cognitive Services
1. [Azure Machine Learning](https://azure.microsoft.com/en-us/services/machine-learning/)
2. [Azure Synapse Analytics](https://azure.microsoft.com/en-us/services/synapse-analytics/)
3. [Azure Cognitive Service](https://azure.microsoft.com/en-us/services/cognitive-services/)
4. [Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/)
5. [Azure Cosmos DB](https://azure.microsoft.com/en-us/services/cosmos-db)
6. [Power Apps](https://docs.microsoft.com/en-us/powerapps/)
7. [Power Virtual Agent](https://powervirtualagents.microsoft.com/)

## Getting Started

1. In the lab setup we have automated the below steps:

   - **Resource Deployment**:  The deployment of Azure Synapse Analytics, Azure Machine Learning and its related resources, Azure Cosmos DB, Function App, Logic App, Speech Service, Translator and Azure Kubernetes Service.

   - **Analytics Deployment**: The Notebooks needed to complete this solution accelerator are setup and executed.

   - **Backend Deployment**: All API services consumed via Power Automate are automated. As Architecture diagram shows all of services will be compiled and deployed in Azure Kuebernetes service.

2. In order to complete the solution accelerator perform the below steps:


## Deploy the resources

1. Copy and paste the below **Link** in the new tab of your browser and launch the template deployment.  Log in to the Azure portal using your credentials if you are prompted to do so.

    ```
    https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FCloudLabsAI-Azure%2FSolution-Accelerators%2Fmain%2FPatient-Risk-Analyzer%2Fdeploy.json
    ```

2. Select the Resource group **solutionaccelarator** from drop-downlist and enter the below details.

    ** Resource group**: click on create new and enter soultion-accelerator, then click on **ok**
    **Azure User Name**: Enter your azure user name
    **Azure Password**: Enter your azure password
    **Deployment ID**: Enter unique number ( ex: 789654)

      ![template deployment](https://github.com/CloudLabsAI-Azure/AIW-Azure-Network-Solutions/blob/main/media/r+d.png?raw=true)

## Deploy and configure the Provider Portal App

1. Go to https://make.preview.powerapps.com/

2. In the right upper corner, make sure you select the correct environment where you want to deploy the Power App.

3. Click on `Apps - Import Canvas App`

4. Click upload and select the [Frontend_Deployment/PatientHubDoctorPortal.zip](./Frontend_Deployment/PatientHubDoctorPortal.zip) Zipfile.

5. Review the package content. You should see the details as the screenshot below

   ![Review Package Content](https://github.com/CloudLabsAI-Azure/Machine-Learning-Patient-Risk-Analyzer-SA/blob/main/Frontend_Deployment/img/ReviewPackageContent.jpg?raw=true)

6. Under the `Review Package Content`, click on the little wrench next to the Application Name `Provider Portal`, to change the name of the Application. Make sure the name is unique for the environemnt.

7. Click Import and wait until you see the message `All package resources were successfully imported.`

8. Click on `Flows`. You will notice that all the flows are disabled. 

   ![Cloud Flows disabled](https://github.com/CloudLabsAI-Azure/Machine-Learning-Patient-Risk-Analyzer-SA/blob/main/Frontend_Deployment/img/CloudFlows.jpg?raw=true)

9. You need to turn them on before you can use them. Hover over each of the flows, select the button `More Commands` and click `Turn on`.

   ![Turn on Cloud Flows](https://github.com/CloudLabsAI-Azure/Machine-Learning-Patient-Risk-Analyzer-SA/blob/main/Frontend_Deployment/img/TurnonCloudFlows.png?raw=true)

10. For each flow, you need to change the HTTP component so that the URI points to your API Services. Edit each flow, open the HTTP component and past the Public IP addresses you noted down in the previous step.
Your URI should look similar like the screenshot below.

   ![HTTP](https://github.com/CloudLabsAI-Azure/Machine-Learning-Patient-Risk-Analyzer-SA/blob/main/Frontend_Deployment/img/HTTP.jpg?raw=true)

| API Service | Flow |
  | ------------- | :------------- | 
  | appointment | PatientHub-GetNextAppointments |
  | batchinference | PatientHub-InferenceExplanation |
  | patient | PatientHub-GetAllPatients | 
  | realtimeinference | PatientHub-RealtimeInference |
  | tts | PatientHub-GetSpeechFile |  


11. After the modification, click the "Test" button in the upper right corner to test the flow. If all went well, you should receive "Your flow ran successfully".

12. Once the flows are modified, you should open the Power App and all should work like a charm.
