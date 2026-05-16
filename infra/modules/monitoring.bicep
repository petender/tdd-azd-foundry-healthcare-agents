@description('Log Analytics workspace name')
param logAnalyticsName string

@description('Application Insights name')
param appInsightsName string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

// Log Analytics Workspace
module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.9.0' = {
  name: '${logAnalyticsName}-deploy'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
    skuName: 'PerGB2018'
    dataRetention: 30
    dailyQuotaGb: 5
  }
}

// Application Insights (workspace-based)
module appInsights 'br/public:avm/res/insights/component:0.4.0' = {
  name: '${appInsightsName}-deploy'
  params: {
    name: appInsightsName
    location: location
    tags: tags
    workspaceResourceId: logAnalytics.outputs.resourceId
    kind: 'web'
    applicationType: 'web'
  }
}

@description('Log Analytics workspace resource ID')
output logAnalyticsId string = logAnalytics.outputs.resourceId

@description('Application Insights resource ID')
output appInsightsId string = appInsights.outputs.resourceId

@description('Application Insights connection string')
output appInsightsConnectionString string = appInsights.outputs.connectionString
