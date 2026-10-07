param workspaceName string
param storageAccountResourceId string
param keyVaultResourceId string
param appInsightsResourceId string
param containerRegistryResourceId string
param confidentialData bool = true
param ipAllowlist array
param logAnalyticsWorkspaceResourceId string

resource workspace 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' = {
  name: workspaceName
  location: resourceGroup().location
  identity: {
    type: 'systemAssigned'
  }
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountResourceId
    keyVault: keyVaultResourceId
    applicationInsights: appInsightsResourceId
    containerRegistry: containerRegistryResourceId
    hbiWorkspace: confidentialData
    systemDatastoresAuthMode: 'identity'
    ipAllowlist: ipAllowlist
  }
}

resource workspaceName_Microsoft_Insights_service 'Microsoft.MachineLearningServices/workspaces/providers/diagnosticSettings@2021-05-01-preview' = {
  name: '${workspaceName}/Microsoft.Insights/service'
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
  dependsOn: [
    workspace
  ]
}
