dataset_maxfiles = 10 # Set to 11973 or 0 to get all the files

import os
from azureml.opendatasets import OjSalesSimulated

# Pull all of the data
oj_sales_files = OjSalesSimulated.get_file_dataset()

# Pull only the first `dataset_maxfiles` files
if dataset_maxfiles:
    oj_sales_files = oj_sales_files.take(dataset_maxfiles)

# Create a folder to download
target_path = 'oj_sales_data' 
os.makedirs(target_path, exist_ok=True)

# Download the data
oj_sales_files.download(target_path, overwrite=True)

from azureml.core.workspace import Workspace
import azureml.core
from azureml.core import Dataset, Workspace, Experiment
from azureml.core.compute import ComputeTarget, AmlCompute

from azureml.core.authentication import ServicePrincipalAuthentication

sub_tenant_id = "cefcb8e7-ee30-49b8-b190-133f1daafd85" 
svc_pr_id = "fd47cfa9-252a-4e9d-849b-0e3e2c89df55"
svc_pr_password="SaB8Q~gJhra1fhlV2tiOyDQg7m.5au-sjQj1vbhJ"


svc_pr = ServicePrincipalAuthentication(
    tenant_id=sub_tenant_id,
    service_principal_id=svc_pr_id,
    service_principal_password=svc_pr_password)


ws = Workspace.get(name = "abc", subscription_id = 'defg', resource_group = 'hij', auth = svc_pr)

blob_datastore_name = "automl_many_models"
container_name = "automl-sample-notebook-data"
account_name = "automlsamplenotebookdata"

from azureml.core import Datastore

datastore = Datastore.register_azure_blob_container(
    workspace=ws, 
    datastore_name=blob_datastore_name, 
    container_name=container_name,
    account_name=account_name,
    create_if_not_exists=True
)

if 0 < dataset_maxfiles < 11973:
    ds_train_path = 'oj_data_small/'
    ds_inference_path = 'oj_inference_small/'
else:
    ds_train_path = 'oj_data/'
    ds_inference_path = 'oj_inference/'

from azureml.core.dataset import Dataset

# Create file datasets
ds_train = Dataset.File.from_files(path=datastore.path(ds_train_path), validate=False)
ds_inference = Dataset.File.from_files(path=datastore.path(ds_inference_path), validate=False)

# Register the file datasets
dataset_name = 'oj_data_small' if 0 < dataset_maxfiles < 11973 else 'oj_data'
train_dataset_name = dataset_name + '_train'
inference_dataset_name = dataset_name + '_inference'
ds_train.register(ws, train_dataset_name, create_new_version=True)
ds_inference.register(ws, inference_dataset_name, create_new_version=True)

oj_ds = Dataset.get_by_name(ws, name=train_dataset_name)
oj_ds

download_paths = oj_ds.download()
download_paths

import pandas as pd

sample_data = pd.read_csv(download_paths[0])
sample_data.head(10)
