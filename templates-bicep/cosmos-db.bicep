param cosmosDbName string

@allowed([
  'GlobalDocumentDB'
  'MongoDB'
])
param cosmosDbType string

@allowed([
  'Eventual'
  'Session'
  'BoundedStaleness'
  'Strong'
  'ConsistentPrefix'
])
param defaultConsistencyLevel string

@allowed([
  '3.2'
  '3.6'
  '4.0'
])
param serverVersion string = '3.6'
param subnetResourceIdList array = []

@description('A comma separated list of single IP addresses and/or CIDR ranges')
param ipRangeFilter string = ''

@description('Log analytics workspace to send logs to (leave blank to disable)')
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

@description('Minimal version of TLS required to access cosmos db')
@metadata({ displayName: 'Minimal TLS Version' })
@allowed([
  'Tls'
  'Tls11'
  'Tls12'
])
param minimalTlsVersion string = 'Tls12'

var apiProperties = {
  apiProperties: {
    serverVersion: serverVersion
  }
}
var baseCosmosProperties = {
  backupPolicy: {
    type: 'Continuous'
  }
  consistencyPolicy: {
    defaultConsistencyLevel: defaultConsistencyLevel
  }
  databaseAccountOfferType: 'Standard'
  ipRules: ipRulesCopy
  isVirtualNetworkFilterEnabled: ((length(virtualNetworkRules) > 0) ? bool('true') : bool('false'))
  locations: [
    {
      locationName: resourceGroup().location
    }
  ]
  virtualNetworkRules: virtualNetworkRules
  minimalTlsVersion: minimalTlsVersion
}
var ipRangeFilterArray = split(ipRangeFilter, ',')
var mongoCosmosProperties = union(baseCosmosProperties, apiProperties)
var virtualNetworkRulesEmpty = []
var virtualNetworkRules = ((length(subnetResourceIdList) > 0) ? virtualNetworkRulesCopy : virtualNetworkRulesEmpty)
var diagnosticSettingsEnabled = (!empty(logAnalyticsWorkspaceName))
var logAnalyticsWorkspaceResourceId = resourceId(
  logAnalyticsWorkspaceResourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspaceName
)
var commonDiagnosticSettings = [
  {
    category: 'ControlPlaneRequests'
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 90
    }
  }
]
var mongoSpecificDiagnosticSettings = [
  {
    category: 'MongoRequests'
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 90
    }
  }
]
var nonMongoSpecificDiagnosticSettings = [
  {
    category: 'DataPlaneRequests'
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 90
    }
  }
]
var mongoDiagnosticSettings = concat(commonDiagnosticSettings, mongoSpecificDiagnosticSettings)
var nonMongoDiagnosticSettings = concat(commonDiagnosticSettings, nonMongoSpecificDiagnosticSettings)
var diagnosticSettings = ((cosmosDbType == 'MongoDB') ? mongoDiagnosticSettings : nonMongoDiagnosticSettings)
var virtualNetworkRulesCopy = [
  for i in range(0, ((length(subnetResourceIdList) > 0) ? length(subnetResourceIdList) : 1)): {
    id: ((length(subnetResourceIdList) > 0) ? subnetResourceIdList[i] : json('null'))
  }
]
var ipRulesCopy = [
  for item in ipRangeFilterArray: {
    ipAddressOrRange: item
  }
]

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: cosmosDbName
  location: resourceGroup().location
  kind: cosmosDbType
  properties: ((cosmosDbType == 'MongoDB') ? mongoCosmosProperties : baseCosmosProperties)
}

resource cosmosDbName_Microsoft_Insights_service 'Microsoft.DocumentDB/databaseAccounts/providers/diagnosticSettings@2021-05-01-preview' = if (diagnosticSettingsEnabled) {
  name: '${cosmosDbName}/Microsoft.Insights/service'
  location: resourceGroup().location
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettings
  }
  dependsOn: [
    cosmosDb
  ]
}
