Start-Service *docker*

#execute deployment script
cd C:\LabFiles

.\deployapp.ps1

#execute pipeline 3 this run 
Set-AzSynapsePipeline -WorkspaceName $synapseworkspaceName -Name "Pipeline 3" -DefinitionFile "C:\LabFiles\Pipeline 3.json"
Invoke-AzSynapsePipeline -WorkspaceName $synapseworkspaceName -PipelineName "Pipeline 3"
