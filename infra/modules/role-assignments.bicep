@description('Key Vault name')
param keyVaultName string

@description('OpenAI account name')
param openAiName string

@description('App Service managed identity principal ID')
param appServicePrincipalId string

@description('Deployer principal ID (from AZURE_PRINCIPAL_ID)')
param deployerPrincipalId string

// Role definition IDs
var cognitiveServicesOpenAiUserRoleId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
var cognitiveServicesOpenAiContributorRoleId = 'a001fd3d-188f-4b5d-821b-7da978bf7442'
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var keyVaultAdminRoleId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'

// Existing resource references
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource openAi 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: openAiName
}

// App Service MI → Cognitive Services OpenAI User on OpenAI account
resource appOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAi.id, appServicePrincipalId, cognitiveServicesOpenAiUserRoleId)
  scope: openAi
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAiUserRoleId)
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

// App Service MI → Key Vault Secrets User on Key Vault
resource appKvRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, appServicePrincipalId, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Deployer → Key Vault Administrator
resource deployerKvRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(deployerPrincipalId)) {
  name: guid(keyVault.id, deployerPrincipalId, keyVaultAdminRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdminRoleId)
    principalId: deployerPrincipalId
    principalType: 'User'
  }
}

// Deployer → Cognitive Services OpenAI Contributor on OpenAI account
resource deployerOpenAiRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(deployerPrincipalId)) {
  name: guid(openAi.id, deployerPrincipalId, cognitiveServicesOpenAiContributorRoleId)
  scope: openAi
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAiContributorRoleId)
    principalId: deployerPrincipalId
    principalType: 'User'
  }
}
