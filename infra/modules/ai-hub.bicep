@description('AI Foundry Hub name')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

@description('Storage account resource ID')
param storageAccountId string

@description('Key Vault resource ID')
param keyVaultId string

@description('Application Insights resource ID')
param appInsightsId string

@description('AI Search resource ID (empty if not deployed)')
param aiSearchId string = ''

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: 'Healthcare AI Foundry Hub'
    description: 'Azure AI Foundry Hub for healthcare agent demos'
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: appInsightsId
    publicNetworkAccess: 'Enabled'
  }
}

// AI Search connection (optional)
resource searchConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = if (!empty(aiSearchId)) {
  parent: aiHub
  name: 'ai-search-connection'
  properties: {
    category: 'CognitiveSearch'
    authType: 'AAD'
    target: aiSearchId
    metadata: {
      ApiType: 'Azure'
      ResourceId: aiSearchId
    }
  }
}

@description('AI Hub resource ID')
output hubId string = aiHub.id

@description('AI Hub name')
output hubName string = aiHub.name

@description('AI Hub endpoint')
output hubEndpoint string = 'https://${name}.${location}.api.azureml.ms'

@description('AI Hub principal ID')
output principalId string = aiHub.identity.principalId
