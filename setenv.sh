#!/bin/bash
# name of resource group and deployment to link all resources together
RESOURCE_GROUP=$(az config get --local defaults.group --query value --output tsv)
AZURE_WORKSPACE=$(az config get --local defaults.workspace --query value --output tsv)
DEPLOYMENT_NAME=rai-workshop

# Azure OpenAI API KEY
echo '------------------------------------------'
echo 'Get OpenAI API KEY'

AOAI_API_KEY=$(az deployment group show  --resource-group $RESOURCE_GROUP --name $DEPLOYMENT_NAME --query "properties.outputs.openAiApiKey.value" -o tsv)

echo $AOAI_API_KEY


# Azure OpenAI API ENDPOINT
echo '------------------------------------------'
echo 'Get OpenAI API ENDPOINT'

AOAI_ENDPOINT_URL=$(az deployment group show --resource-group $RESOURCE_GROUP  --name $DEPLOYMENT_NAME --query "properties.outputs.openAiApiEndpoint.value"  -o tsv)

echo $AOAI_ENDPOINT_URL

# GPT-35-TURBO DEPLOYMENT
echo '------------------------------------------'
echo 'Get gpt-35-turbo deployment name'

GPT_35_TURBO_DEPLOYMENT=$(az deployment group show  --resource-group $RESOURCE_GROUP  --name $DEPLOYMENT_NAME  --query "properties.outputs.gptDeploymentName.value"   -o tsv)

echo $GPT_35_TURBO_DEPLOYMENT


# TEXT-EMBEDDING-ADA-002 DEPLOYMENT
echo '------------------------------------------'
echo 'Get text-embedding-ada-002 deployment name'

TEXT_EMBEDDING_DEPLOYMENT_NAME=$(az deployment group show  --resource-group $RESOURCE_GROUP --name $DEPLOYMENT_NAME --query "properties.outputs.textEmbedDeploymentName.value" -o tsv)

echo $TEXT_EMBEDDING_DEPLOYMENT_NAME

# Azure CONTENT SAFETY API ENDPOINT
echo '------------------------------------------'
echo 'Get CONTENT SAFETY API ENDPOINT'

AZURE_CONTENTSAFETY_ENDPOINT=$(az deployment group show --resource-group $RESOURCE_GROUP --name $DEPLOYMENT_NAME  --query "properties.outputs.contentsafetyEndpoint.value" -o tsv)

echo $AZURE_CONTENTSAFETY_ENDPOINT


# Azure CONTENT SAFETY API KEY
echo '------------------------------------------'
echo 'Get CONTENT SAFETY API KEY'

AZURE_CONTENTSAFETY_KEY=$(az deployment group show --resource-group $RESOURCE_GROUP --name $DEPLOYMENT_NAME --query "properties.outputs.contentsafetyApiKey.value"  -o tsv)

echo $AZURE_CONTENTSAFETY_KEY

# create an environment file
filename=.env
test -f $filename || touch $filename

# write environment variable to file
cat <<EOT >> .env
AZURE_OPENAI_KEY=$AOAI_API_KEY
AZURE_OPENAI_ENDPOINT=$AOAI_ENDPOINT_URL
GPT_35_TURBO_DEPLOYMENT=$GPT_35_TURBO_DEPLOYMENT
AZURE_CONTENTSAFETY_ENDPOINT=$AZURE_CONTENTSAFETY_ENDPOINT
AZURE_CONTENTSAFETY_KEY=$AZURE_CONTENTSAFETY_KEY
EOT


