@description('Specifies the name for Azure Open AI.')
param openaiName string

@description('Specifies the name for Content Safety.')
param contentsafetyName string

param gpt35TurboModelName string = 'gpt-35-turbo'
param textEmbeddingModelName string = 'text-embedding-ada-002'
param chatGptModelVersion string = '0613'
param embeddingDeploymentCapacity int = 5
param chatGptDeploymentCapacity int = 5

param csExists bool = false
param openaiExists bool = false

@description('Display name of GPT-35-Turbo deployment')
param gpt35TurboDeploymentName string

@description('Display name of Text-Embedding-002 deployment')
param embeddingDeploymentName string


@description('Specifies the workspace azureMLname of the deployment.')
param azuremlName string

param workshopName string = 'workshop'

@description('Specifies the location of the Azure Machine Learning workspace and dependent resources.')
@allowed([
  'australiaeast'
  'brazilsouth'
  'canadacentral'
  'centralus'
  'eastasia'
  'eastus'
  'eastus2'
  'francecentral'
  'japaneast'
  'koreacentral'
  'northcentralus'
  'northeurope'
  'southeastasia'
  'southcentralus'
  'uksouth'
  'westcentralus'
  'westus'
  'westus2'
  'westeurope'
])
param location string


var tenantId = subscription().tenantId
var storageAccountName = 'st${azuremlName}${workshopName}'
var keyVaultName = 'kv-${azuremlName}-${workshopName}'
var applicationInsightsName = 'appi-${azuremlName}-${workshopName}'
var containerRegistryName = 'cr${azuremlName}${workshopName}'
var workspaceName = 'aml-w${azuremlName}${workshopName}'
var storageAccountId = storageAccount.id
var keyVaultId = vault.id
var applicationInsightId = applicationInsight.id
var containerRegistryId = registry.id

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enableSoftDelete: true
  }
}

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  sku: {
    name: 'Standard'
  }
  name: containerRegistryName
  location: location
  properties: {
    adminUserEnabled: false
  }
}

resource workspace 'Microsoft.MachineLearningServices/workspaces@2022-10-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  name: azuremlName
  location: location
  properties: {
    friendlyName: azuremlName
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightId
    containerRegistry: containerRegistryId
  }
}

param oaSKU string = 'S0'
resource account1 'Microsoft.CognitiveServices/accounts@2022-03-01' = if (!openaiExists) {
  name: openaiName
  location: location
  kind: 'OpenAI'
  sku: {
    name: oaSKU
  }
  properties: {
    customSubDomainName: openaiName
  }
}

param csSKU string = 'S0'
resource contentsafetyaccount 'Microsoft.CognitiveServices/accounts@2022-03-01' = if (!csExists) {
  name: contentsafetyName
  location: location
  kind: 'ContentSafety'
  sku: {
    name: csSKU
  }
  properties: {
    customSubDomainName: contentsafetyName
  }
}

resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: account1
  name: gpt35TurboDeploymentName
  properties: {
    model: {
         format: 'OpenAI'
         name: gpt35TurboModelName
         version: chatGptModelVersion
        }
  }
  sku:  {
    name: 'Standard'
    capacity: chatGptDeploymentCapacity
  }

}


resource embedDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: account1
  name: embeddingDeploymentName
  properties: {
     model: {
         format: 'OpenAI'
         name: textEmbeddingModelName
         version: '2'
        }   
    
  }
  sku:  {
    name: 'Standard'
    capacity: embeddingDeploymentCapacity
  }
  dependsOn: [
    gptDeployment
  ]
}

output openAIServiceName string = openaiName
output gptDeploymentName string =  gpt35TurboDeploymentName
output textEmbedDeploymentName string = embeddingDeploymentName 

output openAiApiEndpoint string = account1.properties.endpoint
output openAiApiKey string = account1.listKeys().key1
output contentsafetyEndpoint string = contentsafetyaccount.properties.endpoint
output contentsafetyApiKey string = contentsafetyaccount.listKeys().key1
