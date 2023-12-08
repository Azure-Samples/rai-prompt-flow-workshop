#!/bin/bash
# name of resource group and azure ml workspace from global config setting
#rg_name=$(az config get --local defaults.group --query value --output tsv)
rg_name=$(az group list --query "[?name=='testlabRG'].name" --output tsv)
ws_name=azml-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1)
openaiName=my-azure-openai-srv$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
region=eastus
gpt35DeploymentName=my-gpt-35-turbo-test$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
textEmbedDeploymentName=my-text-embedding-ada-002-test
contentSafetyName=my-content-safety-srv$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
ContainerRegName=myacregistry$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
ComputeName=computeinstance$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)


echo $rg_name

# Create Resource Group
echo '------------------------------------------'
echo 'Creating Resource group...'

while [ -z "$rg_name" ]
do
	if [ $(az group exists --name $rg_name) = false ]; then
	    az group create --name $rg_name --location $region
	else
	   uuid=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
	   rg_name=rai-$uuid-RG
	fi
done


# Create OpenAI
echo '------------------------------------------'
echo 'Create an OpenAI instance'
az cognitiveservices account create --name $openaiName --resource-group $rg_name --location $region --kind OpenAI --sku s0 


# Deploy OpenAI model gpt-35-turbo
echo '------------------------------------------'
echo 'Create an OpenAI model gpt-35-turbo'
az cognitiveservices account deployment create --name $openaiName --resource-group  $rg_name --deployment-name $gpt35DeploymentName --model-name gpt-35-turbo --model-version "0301" --model-format OpenAI


# Deploy OpenAI model text-embedding-ada-002
echo '------------------------------------------'
echo 'Create an OpenAI model text-embedding-ada-002'
az cognitiveservices account deployment create --name $openaiName --resource-group  $rg_name --deployment-name $textEmbedDeploymentName --model-name ada --model-version "1" --model-format OpenAI 


# Create Azure Content Safety
echo '------------------------------------------'
echo 'Create an Azure Content Safety instance'
az cognitiveservices account create --name $contentSafetyName --resource-group $rg_name --location $region --kind ContentSafety --sku s0 

# Create Container Registry
echo '------------------------------------------'
echo 'Creating an Container Registry...'
#az ml registry create --resource-group $rg_name --name $ContainerRegName 



# Create Azure Machine Learning workspace
echo '------------------------------------------'
echo 'Create an Azure Machine Learning workspace'

az ml workspace create --name $ws_name --resource-group $rg_name


# generate unique compute name
uuid=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
computename=compute-$uuid

# Create compute instance
echo '------------------------------------------'
echo 'Creating a Compute Instance'
# az ml compute create -f cloud/compute-cpu.yml 

while [ ! -z "$ComputeName" ]
do
	if [ $(az ml compute list --query "[?name=='$ComputeName']" --output tsv) = false ]; then
	    az ml compute create --name $ComputeName -w $ws_name -g $rg_name --type AmlCompute --size STANDARD_DS12_V2 --identity-type SystemAssigned
	else
	   uuid=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
	   ComputeName=rai-$uuid-vm
	fi
done

echo 'compute name - created: ' $ComputeName

echo '--------------------------------------------------------'
echo '  Please verify that the resources are created in the Azure portal (https://ml.azure.com)'
echo '--------------------------------------------------------'