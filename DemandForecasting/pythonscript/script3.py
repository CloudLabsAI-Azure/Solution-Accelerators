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

textfile = open("runid.txt", "w")
a = textfile.write('a=')
b = textfile.write(myrunid) 
textfile.close()

run.wait_for_completion(show_output=True)


from scripts.helper import get_training_output
import os

training_results_name = "training_results"
training_output_name = "many_models_training_output"

training_file = get_training_output(run, training_results_name, training_output_name)
all_columns = ["Framework", "Dataset", "Run", "Status", "Model", "Tags", "StartTime", "EndTime" , "ErrorType", "ErrorCode", "ErrorMessage" ]
df = pd.read_csv(training_file, delimiter=" ", header=None, names=all_columns)
training_csv_file = "training.csv"
df.to_csv(training_csv_file)
print("Training output has", df.shape[0], "rows. Please open", os.path.abspath(training_csv_file), "to browse through all the output.")

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
