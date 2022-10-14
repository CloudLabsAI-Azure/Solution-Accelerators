# Steps to take before Deploying

1. Create A Resource Group:
    1. Navigate to resource groups in Azure, and click on **Create**.
    2. Make sure to select a subscription, and provide the resource group name: "many-models".
    3. Under resource details, select the dropdown for **Region**, and select any region you wish to deploy.
2. User need to have  **Azure-hpc subscription role** on the subscription.
3. User should have **Owner role** on subscription.

# Deployment Steps

When you are ready to DEPLOY - Click on the **Deploy to Azure** button:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FCloudLabsAI-Azure%2FSolution-Accelerators%2Fmain%2FAzure%20Synapse%20Content%20Recommendations%20Solution%20Accelerator%2Fdeploy01.json))

Below is a sample view of the initial Azure deployment screen and the parameter values required:

1. Make sure to select a subsription.
2. Select the resource group created earlier.
3. And provide the necessary details for the remaining fields( including the service principal details copied earlier in a notepad).

   <img width="368" alt="image" src="https://user-images.githubusercontent.com/83011430/195091911-12a3e24e-6d01-4ef3-a25f-2c476481518e.png">
