Start-Service *docker*

#execute deployment script
cd C:\LabFiles

.\deployapp.ps1

#execute pipeline 3 this run 
Set-AzSynapsePipeline -WorkspaceName $synapseworkspaceName -Name "Pipeline 3" -DefinitionFile "C:\LabFiles\Pipeline 3.json"
Invoke-AzSynapsePipeline -WorkspaceName $synapseworkspaceName -PipelineName "Pipeline 3"


$appointment= kubectl get service/appointment -o jsonpath="{.status.loadBalancer.ingress[0].ip}" -n patienthub
$batchinference = kubectl get service/batchinference -o jsonpath="{.status.loadBalancer.ingress[0].ip}" -n patienthub
$patient= kubectl get service/patient -o jsonpath="{.status.loadBalancer.ingress[0].ip}" -n patienthub
$realtimeinference= kubectl get service/realtimeinference -o jsonpath="{.status.loadBalancer.ingress[0].ip}" -n patienthub
$tts= kubectl get service/tts -o jsonpath="{.status.loadBalancer.ingress[0].ip}" -n patienthub
