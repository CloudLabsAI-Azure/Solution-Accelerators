# AI-Powered Insurance Claims Automation Solution Accelerator

Handling Claims processing through an intelligent agent with cognitive skills to handle image, ID, and documents with goal to reduce claims processing time and manual effort in end-to-end claims processing for better customer experience

The solution will showcase Azure platform’s machine learning capability to recognize document type, extract required fields and push data to downstream applications, significantly reducing manual efforts and creating smoother customer experience.

## Architecture

![image](https://user-images.githubusercontent.com/33771500/196611366-01d772c5-bdee-4a0b-9779-bc2cbf1784d3.png)

## Process-Flow

* Customer uses voice activated intelligent agent to file a new claim via the Chat bots
* Customer uploads the claim related document (taking pictures or uploading the images from the library) via the bot (Driving License, Insurance Card, Service Estimate, Damage of the Windshield)
*	In the backend, the data is uploaded to **Azure Storage Services**
*	The logic app will process the uploaded documents and images from the blob storage
* Logic app will
    *	Extract the metadata from out of the box model related documents (like ID and Invoices)<br>
    *	Extract the metadata from the custom models (like insurance card)
    *	Data will be persisted and stored into data store(cosmos Db)
* Cognitive Search Indexer will trigger index the documents<br>
* Custom UI provides the search capability into indexed document repository in Azure Search

## Get Started
To get started, follow the steps outlined in the link below:

[Deployment_Steps](https://github.com/CloudLabsAI-Azure/Solution-Accelerators/blob/main/AI-Powered-Insurance-Claims-Automation-Solution-Accelerator/Deployment/Deployment.md)
> A VM is deployed along with the template provided in [Deployment_Steps](https://github.com/CloudLabsAI-Azure/Solution-Accelerators/blob/main/AI-Powered-Insurance-Claims-Automation-Solution-Accelerator/Deployment/Deployment.md) to make testing/performing the solution accelerator easier for users/learners who are using Mac/Linux OS, and has required software tools installed for users/learners to complete the solution accelerator, and they need not install additional software tools on their PC/machine for this purpose.

> You can connect to the VM post [Deployment_Steps](https://github.com/CloudLabsAI-Azure/Solution-Accelerators/blob/main/Smart-Spaces-Sustainability/Deployment/Deployment.md) by RDP protocol, and using the **VM DNS Name, adminUsername, and adminPassword** from declaring these values in [Deployment_Steps](https://github.com/CloudLabsAI-Azure/Solution-Accelerators/blob/main/AI-Powered-Insurance-Claims-Automation-Solution-Accelerator/Deployment/Deployment.md).

## Additional Notes

The deployment time for this solution accelerator takes around 20-25 mins., even though the template deployment may show complete in Azure. Please wait 20-25 mins. before performing the lab because of PowerShell scripts running inside the VM.

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
