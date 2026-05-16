@description('AI Foundry Project name')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

@description('Parent Hub resource ID')
param hubId string

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: 'Healthcare Agents Project'
    description: 'AI Foundry Project for healthcare agent development and demos'
    hubResourceId: hubId
    publicNetworkAccess: 'Enabled'
  }
}

@description('AI Project resource ID')
output projectId string = aiProject.id

@description('AI Project name')
output projectName string = aiProject.name

@description('AI Project principal ID')
output principalId string = aiProject.identity.principalId
