@description('AI Search service name')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

resource search 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'free'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}

@description('AI Search resource ID')
output searchId string = search.id

@description('AI Search service name')
output searchName string = search.name

@description('AI Search endpoint')
output endpoint string = 'https://${name}.search.windows.net'
