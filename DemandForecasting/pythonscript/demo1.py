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


datastore = ws.get_default_datastore()



cpu_cluster_name = 'cpucluster'


# We create a STANDARD_D13_V2 compute cluster. D-series VMs are used for tasks that require higher compute power and temporary disk performance. This [page](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs) will give you more information on VM sizes to help you decide which will best fit your use case.

# In[ ]:


from azureml.core.compute import ComputeTarget, AmlCompute
from azureml.core.compute_target import ComputeTargetException

# Verify that cluster does not exist already
try:
    cpu_cluster = ComputeTarget(workspace=ws, name=cpu_cluster_name)
    print('Found an existing cluster, using it instead.')
except ComputeTargetException:
    compute_config = AmlCompute.provisioning_configuration(vm_size='STANDARD_D13_V2',
                                                           min_nodes=0,
                                                           max_nodes=20)
    cpu_cluster = ComputeTarget.create(ws, cpu_cluster_name, compute_config)
    cpu_cluster.wait_for_completion(show_output=True)
