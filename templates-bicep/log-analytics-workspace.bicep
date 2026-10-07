param logAnalyticsWorkspaceName string

@allowed([
  'PerGB2018'
  'PerNode'
])
param logAnalyticsWorkspaceSku string

@minValue(31)
@maxValue(90)
param dataRetentionDays int = 31

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
    retentionInDays: dataRetentionDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output resourceId string = reference(logAnalyticsWorkspaceName, '2020-08-01', 'Full').resourceId
output fullyQualifiedResourceId string = '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/${reference(logAnalyticsWorkspaceName,'2020-08-01','Full').resourceId}'
