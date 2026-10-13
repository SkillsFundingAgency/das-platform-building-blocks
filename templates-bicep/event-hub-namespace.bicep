param eventHubNamespaceName string

@allowed([
  'Basic'
  'Standard'
])
param eventHubTier string

@minValue(1)
@maxValue(20)
param eventHubCapacity int = 1
param isAutoInflateEnabled bool = false

@description('Upper limit for Auto Inflate scaling')
@minValue(0)
@maxValue(20)
param maximumThroughputUnits int = 0

@description('The name of the Log Analytics workspace to send diagnostic logs to.')
param logAnalyticsWorkspaceName string

@description('The resource group name of the Log Analytics workspace.')
param logAnalyticsWorkspaceResourceGroupName string

var logAnalyticsWorkspaceResourceId = resourceId(
  logAnalyticsWorkspaceResourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspaceName
)

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: eventHubNamespaceName
  location: resourceGroup().location
  sku: {
    name: eventHubTier
    tier: eventHubTier
    capacity: eventHubCapacity
  }
  properties: {
    isAutoInflateEnabled: isAutoInflateEnabled
    maximumThroughputUnits: maximumThroughputUnits
  }
}

resource eventHubNamespaceName_Microsoft_Insights_service 'Microsoft.EventHub/namespaces/providers/diagnosticSettings@2021-05-01-preview' = {
  name: '${eventHubNamespaceName}/Microsoft.Insights/service'
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
    eventHubNamespace
  ]
}
