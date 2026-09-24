param logAnalyticsWorkspaceName string

@allowed([
  'PerGB2018'
  'PerNode'
])
param logAnalyticsWorkspaceSku string

@minValue(31)
@maxValue(730)
param dataRetentionDays int = 31
param totalRetentionInDays int = -1
param tableNames array = []
param dailyQuotaGb int = -1

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
param disableLocalAuth bool = false
param enableDataExport bool = false

@allowed([
  'Analytics'
  'Basic'
  'Auxiliary'
])
param tablePlan string = 'Analytics'

@allowed([
  'None'
  'CanNotDelete'
])
param resourceLockLevel string = 'None'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
    retentionInDays: dataRetentionDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    workspaceCapping: ((dailyQuotaGb == -1)
      ? json('null')
      : {
          dailyQuotaGb: dailyQuotaGb
        })
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: disableLocalAuth
      enableDataExport: enableDataExport
    }
  }
}

resource logAnalyticsWorkspaceName_tableNames 'Microsoft.OperationalInsights/workspaces/tables@2023-09-01' = [
  for item in tableNames: {
    name: '${logAnalyticsWorkspaceName}/${item}'
    properties: {
      plan: tablePlan
      retentionInDays: dataRetentionDays
      totalRetentionInDays: totalRetentionInDays
    }
    dependsOn: [
      logAnalyticsWorkspace
    ]
  }
]

resource logAnalyticsWorkspaceName_lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLockLevel != 'None') {
  scope: logAnalyticsWorkspace
  name: '${logAnalyticsWorkspaceName}-lock'
  properties: {
    level: resourceLockLevel
    notes: 'Prevents deletion of the workspace. Does not prevent a data purge.'
  }
}

output resourceId string = reference(logAnalyticsWorkspaceName, '2020-08-01', 'Full').resourceId
output fullyQualifiedResourceId string = '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/${reference(logAnalyticsWorkspaceName,'2020-08-01','Full').resourceId}'
