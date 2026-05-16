@description('App Service Plan name')
param planName string

@description('App Service name')
param appName string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

@description('Application Insights connection string')
param appInsightsConnectionString string

@description('Azure OpenAI endpoint')
param openAiEndpoint string

@description('AI Foundry Project endpoint')
param aiProjectEndpoint string

// App Service Plan (AVM)
module plan 'br/public:avm/res/web/serverfarm:0.4.0' = {
  name: '${planName}-deploy'
  params: {
    name: planName
    location: location
    tags: tags
    kind: 'linux'
    skuName: 'B1'
    reserved: true
  }
}

// App Service (AVM)
module app 'br/public:avm/res/web/site:0.12.0' = {
  name: '${appName}-deploy'
  params: {
    name: appName
    location: location
    tags: union(tags, { 'azd-service-name': 'web' })
    kind: 'app,linux'
    serverFarmResourceId: plan.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|10.0'
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      alwaysOn: true
      http20Enabled: true
    }
    appSettingsKeyValuePairs: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
      AZURE_OPENAI_ENDPOINT: openAiEndpoint
      AZURE_AI_PROJECT_ENDPOINT: aiProjectEndpoint
    }
  }
}

@description('App Service resource ID')
output appId string = app.outputs.resourceId

@description('App Service name')
output appName string = app.outputs.name

@description('App Service default hostname')
output defaultHostName string = app.outputs.defaultHostname

@description('App Service managed identity principal ID')
output principalId string = app.outputs.systemAssignedMIPrincipalId
