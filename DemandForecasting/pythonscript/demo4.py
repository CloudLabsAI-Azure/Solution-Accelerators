import azureml.core
import pandas as pd


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

ws.get_details()


# set up datastores
dstore = ws.get_default_datastore()

output = {}
output['SDK version'] = azureml.core.VERSION
output['Subscription ID'] = ws.subscription_id
output['Workspace'] = ws.name
output['Resource Group'] = ws.resource_group
output['Location'] = ws.location
output['Default datastore name'] = dstore.name
pd.set_option('display.max_colwidth', -1)
outputDf = pd.DataFrame(data = output, index = [''])
outputDf.T

from azureml.core import Experiment

experiment = Experiment(ws, 'manymodels-training-pipeline')

print('Experiment name: ' + experiment.name)


from azureml.core.dataset import Dataset

filedst_10_models = Dataset.get_by_name(ws, name='oj_data_small_train')
filedst_10_models_input = filedst_10_models.as_named_input('train_10_models')

#filedst_all_models = Dataset.get_by_name(ws, name='oj_data_train')
#filedst_all_models_inputs = filedst_all_models.as_named_input('train_all_models')

from azureml.core.compute import AmlCompute
from azureml.core.compute import ComputeTarget

# Choose a name for your cluster.
amlcompute_cluster_name = "cpucluster"

found = False
# Check if this compute target already exists in the workspace.
cts = ws.compute_targets
if amlcompute_cluster_name in cts and cts[amlcompute_cluster_name].type == 'AmlCompute':
    found = True
    print('Found existing compute target.')
    compute = cts[amlcompute_cluster_name]
    
if not found:
    print('Creating a new compute target...')
    provisioning_config = AmlCompute.provisioning_configuration(vm_size='STANDARD_D16S_V3',
                                                           min_nodes=2,
                                                           max_nodes=20)
    # Create the cluster.
    compute = ComputeTarget.create(ws, amlcompute_cluster_name, provisioning_config)
    
print('Checking cluster status...')
# Can poll for a minimum number of nodes and for a specific timeout.
# If no min_node_count is provided, it will use the scale settings for the cluster.
compute.wait_for_completion(show_output = True, min_node_count = None, timeout_in_minutes = 20)
    
# For a more detailed view of current AmlCompute status, use get_status().

import logging

partition_column_names = ['Store', 'Brand']

automl_settings = {
    "task" : 'forecasting',
    "primary_metric" : 'normalized_root_mean_squared_error',
    "iteration_timeout_minutes" : 10, # This needs to be changed based on the dataset. We ask customer to explore how long training is taking before settings this value
    "iterations" : 15,
    "experiment_timeout_hours" : 1,
    "label_column_name" : 'Quantity',
    "n_cross_validations" : 3,
    # "verbosity" : logging.INFO, 
    # "debug_log": 'automl_oj_sales_debug.txt',
    "time_column_name": 'WeekStarting',
    "max_horizon" : 20,
    "track_child_runs": False,
    "partition_column_names": partition_column_names,
    "grain_column_names": ['Store', 'Brand'],
    "pipeline_fetch_max_batch_size": 15
}

from azureml.contrib.automl.pipeline.steps import AutoMLPipelineBuilder

train_steps = AutoMLPipelineBuilder.get_many_models_train_steps(experiment=experiment,
                                                                automl_settings=automl_settings,
                                                                train_data=filedst_10_models_input,
                                                                compute_target=compute,
                                                                partition_column_names=partition_column_names,
                                                                node_count=2,
                                                                process_count_per_node=8,
                                                                run_invocation_timeout=3700,
                                                                output_datastore=dstore)

from azureml.pipeline.core import Pipeline
#from azureml.widgets import RunDetails

pipeline = Pipeline(workspace=ws, steps=train_steps)
run = experiment.submit(pipeline)
myrunid=experiment.submit(pipeline).id
#RunDetails(run).show()

run.wait_for_completion(show_output=True)

published_pipeline = pipeline.publish(name = 'automl_train_many_models',
                                      description = 'train many models',
                                     version = '1',
                                     continue_on_step_failure = False)
from azureml.pipeline.core import Schedule, ScheduleRecurrence
    
training_pipeline_id = published_pipeline.id

recurrence = ScheduleRecurrence(frequency="Month", interval=1, start_time="2020-01-01T09:00:00")
recurring_schedule = Schedule.create(ws, name="automl_training_recurring_schedule",                             description="Schedule Training Pipeline to run on the first day of every month",
                             pipeline_id=training_pipeline_id, 
                             experiment_name=experiment.name, 
                             recurrence=recurrence)


#notebook4

import azureml.core
import pandas as pd


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

ws.get_details()


# set up datastores
dstore = ws.get_default_datastore()

output = {}
output['SDK version'] = azureml.core.VERSION
output['Subscription ID'] = ws.subscription_id
output['Workspace'] = ws.name
output['Resource Group'] = ws.resource_group
output['Location'] = ws.location
output['Default datastore name'] = dstore.name
pd.set_option('display.max_colwidth', -1)
outputDf = pd.DataFrame(data = output, index = [''])
outputDf.T




from azureml.core.compute import AmlCompute, ComputeTarget

# Choose a name for your cluster.
amlcompute_cluster_name = "cpucluster"

found = False
# Check if this compute target already exists in the workspace.
cts = ws.compute_targets
if amlcompute_cluster_name in cts and cts[amlcompute_cluster_name].type == 'AmlCompute':
    found = True
    print('Found existing compute target.')
    compute = cts[amlcompute_cluster_name]
    
if not found:
    print('Creating a new compute target...')
    provisioning_config = AmlCompute.provisioning_configuration(vm_size='STANDARD_D16S_V3',
                                                           min_nodes=2,
                                                           max_nodes=20)
    # Create the cluster.
    compute = ComputeTarget.create(ws, amlcompute_cluster_name, provisioning_config)
    
print('Checking cluster status...')
# Can poll for a minimum number of nodes and for a specific timeout.
# If no min_node_count is provided, it will use the scale settings for the cluster.
compute.wait_for_completion(show_output = True, min_node_count = None, timeout_in_minutes = 20)
    
# For a more detailed view of current AmlCompute status, use get_status().



from azureml.core import Experiment

experiment = Experiment(ws, 'manymodels-forecasting-pipeline')




from azureml.core.dataset import Dataset

filedst_10_models = Dataset.get_by_name(ws, name='oj_data_small_inference')
filedst_10_models_input = filedst_10_models.as_named_input('forecast_10_models')
 
#filedst_all_models = Dataset.get_by_name(ws, name='oj_data_inference')
#filedst_all_models_input = filedst_all_models.as_named_input('forecast_all_models')



training_experiment_name = "manymodels-training-pipeline"
training_pipeline_run_id = myrunid


from azureml.contrib.automl.pipeline.steps import AutoMLPipelineBuilder

partition_column_names = ['Store', 'Brand']

inference_steps = AutoMLPipelineBuilder.get_many_models_batch_inference_steps(experiment=experiment,
                                                                              inference_data=filedst_10_models_input,
                                                                              compute_target=compute,
                                                                              node_count=2,
                                                                              process_count_per_node=8,
                                                                              run_invocation_timeout=300,
                                                                              output_datastore=dstore,
                                                                              train_experiment_name=training_experiment_name,
                                                                              train_run_id=training_pipeline_run_id,
                                                                              partition_column_names=partition_column_names,
                                                                              time_column_name="WeekStarting",
                                                                              target_column_name="Quantity")



from azureml.pipeline.core import Pipeline

pipeline = Pipeline(workspace = ws, steps=inference_steps)
run = experiment.submit(pipeline)



run.wait_for_completion(show_output=True)



new_working_directory = "C:\AllFiles\solution-accelerator-many-models-master\Automated_ML\03_AutoML_Forecasting_Pipeline\scripts"
os.chdir(new_working_directory)


import pandas as pd
import shutil
import os
import sys 
from helper import get_forecasting_output

forecasting_results_name = "forecasting_results"
forecasting_output_name = "many_models_inference_output"

forecast_file = get_forecasting_output(run, forecasting_results_name, forecasting_output_name)
df = pd.read_csv(forecast_file, delimiter=" ", header=None)
df.columns = ["Week Starting", "Store", "Brand", "Quantity",  "Advert", "Price" , "Revenue", "Predicted" ]
print("Prediction has ", df.shape[0], " rows. Here the first 10 rows are being displayed.")
df.head(10)





published_pipeline = pipeline.publish(name = 'automl_forecast_many_models',
                                      description = 'forecast many models',
                                      version = '1',
                                      continue_on_step_failure = False)



from azureml.pipeline.core import Schedule, ScheduleRecurrence
    
forecasting_pipeline_id = published_pipeline.id

recurrence = ScheduleRecurrence(frequency="Month", interval=1, start_time="2020-01-01T09:00:00")
recurring_schedule = Schedule.create(ws, name="automl_forecasting_recurring_schedule", 
                             description="Schedule Forecasting Pipeline to run on the first day of every week",
                             pipeline_id=forecasting_pipeline_id, 
                             experiment_name=experiment.name, 
                             recurrence=recurrence)
