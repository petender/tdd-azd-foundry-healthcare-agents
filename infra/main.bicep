targetScope = 'resourceGroup'

// Parameters
@description('Primary location for supporting infrastructure')
param location string = 'eastus2'

@description('Location for AI services (OpenAI, AI Foundry, AI Search)')
param aiLocation string = 'swedencentral'

@description('Environment name')
param environment string = 'dev'

@description('Project name used for resource naming')
param projectName string = 'foundry-healthcare-agents'

@description('Principal ID of the deploying user. Azure Developer CLI populates this automatically.')
param principalId string

@description('Deploy AI Search for optional RAG pattern')
param deploySearch bool = true

// Variables
var uniqueSuffix = uniqueString(resourceGroup().id)
var shortName = 'fha'
var tags = {
  Environment: environment
  ManagedBy: 'Bicep'
  Project: projectName
  SecurityControl: 'Ignore'
}

// Naming
var logAnalyticsName = 'log-${shortName}-${environment}-${take(uniqueSuffix, 6)}'
var appInsightsName = 'appi-${shortName}-${environment}-${take(uniqueSuffix, 6)}'
var kvName = 'kv-${shortName}-${environment}-${take(uniqueSuffix, 6)}'
var storageName = 'st${shortName}${environment}${take(uniqueSuffix, 6)}'
var aspName = 'asp-${shortName}-${environment}'
var appName = 'app-${shortName}-${environment}-${take(uniqueSuffix, 6)}'
var aiHubName = 'hub-${shortName}-${environment}-${take(uniqueSuffix, 6)}'
var aiProjectName = 'proj-${shortName}-${environment}-${take(uniqueSuffix, 6)}'
var openAiName = 'oai-${shortName}-${environment}-${take(uniqueSuffix, 6)}'
var searchName = 'srch-${shortName}-${environment}-${take(uniqueSuffix, 6)}'

// Tag the resource group
resource rgTags 'Microsoft.Resources/tags@2024-03-01' = {
  name: 'default'
  properties: { tags: tags }
}

// Module: Monitoring (Log Analytics + App Insights)
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deploy'
  params: {
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
    location: location
    tags: tags
  }
}

// Module: Key Vault (AVM)
module keyVault 'br/public:avm/res/key-vault/vault:0.11.0' = {
  name: 'keyvault-deploy'
  params: {
    name: kvName
    location: location
    tags: tags
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    diagnosticSettings: [
      {
        workspaceResourceId: monitoring.outputs.logAnalyticsId
      }
    ]
  }
}

// Module: Storage Account (AVM)
module storageAccount 'br/public:avm/res/storage/storage-account:0.14.0' = {
  name: 'storage-deploy'
  params: {
    name: storageName
    location: location
    tags: tags
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    diagnosticSettings: [
      {
        workspaceResourceId: monitoring.outputs.logAnalyticsId
      }
    ]
  }
}

// Module: OpenAI (Cognitive Services with GPT-4o)
module openAi 'modules/openai.bicep' = {
  name: 'openai-deploy'
  params: {
    name: openAiName
    location: aiLocation
    tags: tags
    logAnalyticsId: monitoring.outputs.logAnalyticsId
  }
}

// Module: AI Search (optional — declared before AI Hub for dependency clarity)
module search 'modules/search.bicep' = if (deploySearch) {
  name: 'search-deploy'
  params: {
    name: searchName
    location: aiLocation
    tags: tags
  }
}

// Module: AI Foundry Hub
module aiHub 'modules/ai-hub.bicep' = {
  name: 'ai-hub-deploy'
  params: {
    name: aiHubName
    location: aiLocation
    tags: tags
    storageAccountId: storageAccount.outputs.resourceId
    keyVaultId: keyVault.outputs.resourceId
    appInsightsId: monitoring.outputs.appInsightsId
    aiSearchId: deploySearch ? search.outputs.searchId : ''
  }
}

// Module: AI Foundry Project
module aiProject 'modules/ai-project.bicep' = {
  name: 'ai-project-deploy'
  params: {
    name: aiProjectName
    location: aiLocation
    tags: tags
    hubId: aiHub.outputs.hubId
  }
}

// Module: App Service (Plan + Web App)
module appService 'modules/app-service.bicep' = {
  name: 'appservice-deploy'
  params: {
    planName: aspName
    appName: appName
    location: location
    tags: tags
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    openAiEndpoint: openAi.outputs.endpoint
    aiProjectEndpoint: aiHub.outputs.hubEndpoint
  }
}

// Module: Role Assignments (deployed after all resources exist)
module roleAssignments 'modules/role-assignments.bicep' = {
  name: 'role-assignments-deploy'
  params: {
    keyVaultName: kvName
    openAiName: openAiName
    appServicePrincipalId: appService.outputs.principalId
    deployerPrincipalId: principalId
  }
}

// Outputs
output AZURE_OPENAI_ENDPOINT string = openAi.outputs.endpoint
output AZURE_AI_HUB_NAME string = aiHub.outputs.hubName
output AZURE_AI_PROJECT_NAME string = aiProject.outputs.projectName
output AZURE_APP_SERVICE_NAME string = appService.outputs.appName
output AZURE_KEY_VAULT_NAME string = kvName
output AZURE_STORAGE_ACCOUNT_NAME string = storageName
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.appInsightsConnectionString
