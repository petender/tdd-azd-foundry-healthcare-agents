using './main.bicep'

param location = readEnvironmentVariable('AZURE_LOCATION', 'eastus2')
param aiLocation = readEnvironmentVariable('AZURE_AI_LOCATION', 'swedencentral')
param environment = 'dev'
param projectName = 'foundry-healthcare-agents'
param principalId = readEnvironmentVariable('AZURE_PRINCIPAL_ID', '')
param deploySearch = true
