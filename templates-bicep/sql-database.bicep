param databaseName string
param sqlServerName string
param elasticPoolName string = ''
param databaseSkuName string = ''
param databaseSizeBytes string = ''

@allowed([
  ''
  'Basic'
  'Standard'
  'Premium'
  'GeneralPurpose'
  'BusinessCritical'
  'Hyperscale'
])
param databaseTier string = ''
param serverlessMinCapacity string = ''
param serverlessAutoPauseDelay string = '-1'

@description('Semi-colon separated list of database principals who are exempt from the following data masking rules')
param dataMaskingExemptPrincipals string = ''

@description('Object array where object is of type DataMaskingRuleProperties: https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases/datamaskingpolicies/rules#DataMaskingRuleProperties')
param dataMaskingRules array = []

@metadata({
  descrtiption: 'The number of days that diagnostic logs will be stored for. Default value is forever, max is 1 year.'
})
@minValue(0)
@maxValue(365)
param diagnosticsRetentionDays int = 0

@description('The id of the subscription for the Log Analytics Workspace. This defaults to the current subscription.')
param logAnalyticsSubscriptionId string = subscription().subscriptionId

@description('The resource group of the Log Analytics Workspace.')
param logAnalyticsResourceGroup string

@description('The name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

var deployToElasticPool = (length(elasticPoolName) > 0)
var databaseSettings = {
  nonElasticPool: {
    sku: {
      name: databaseSkuName
      tier: databaseTier
    }
    properties: {
      maxSizeBytes: databaseSizeBytes
      minCapacity: serverlessMinCapacity
      autoPauseDelay: serverlessAutoPauseDelay
    }
  }
  elasticPool: {
    sku: {
      name: 'ElasticPool'
    }
    properties: {
      elasticPoolId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Sql/servers/${sqlServerName}/elasticPools/${elasticPoolName}'
    }
  }
}
var diagnosticsSettings = [
  'QueryStoreRuntimeStatistics'
  'QueryStoreWaitStatistics'
  'Errors'
  'DatabaseWaitStatistics'
  'Timeouts'
  'Blocks'
  'SQLInsights'
  'AutomaticTuning'
  'Deadlocks'
]

resource sqlServerName_database 'Microsoft.Sql/servers/databases@2017-10-01-preview' = {
  name: '${sqlServerName}/${databaseName}'
  location: resourceGroup().location
  sku: (deployToElasticPool ? databaseSettings.elasticPool.sku : databaseSettings.nonElasticPool.sku)
  properties: (deployToElasticPool
    ? databaseSettings.elasticPool.properties
    : databaseSettings.nonElasticPool.properties)
}

resource sqlServerName_databaseName_current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-11-01-preview' = {
  parent: sqlServerName_database
  name: 'current'
  properties: {
    state: 'Enabled'
  }
}

resource sqlServerName_databaseName_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-11-01-preview' = {
  parent: sqlServerName_database
  name: 'default'
  properties: {
    diffBackupIntervalInHours: 24
    retentionDays: 35
  }
  dependsOn: [
    sqlServerName_databaseName_current
  ]
}

resource sqlServerName_databaseName_Microsoft_Insights_service 'Microsoft.Sql/servers/databases/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${sqlServerName}/${databaseName}/Microsoft.Insights/service'
  properties: {
    workspaceId: resourceId(
      logAnalyticsSubscriptionId,
      logAnalyticsResourceGroup,
      'Microsoft.OperationalInsights/Workspaces',
      logAnalyticsWorkspaceName
    )
    logs: [
      for item in diagnosticsSettings: {
        category: item
        enabled: true
        retentionPolicy: {
          days: diagnosticsRetentionDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: diagnosticsRetentionDays
        }
      }
    ]
  }
  dependsOn: [
    sqlServerName_database
  ]
}

resource Microsoft_Sql_servers_databases_dataMaskingPolicies_sqlServerName_databaseName_Default 'Microsoft.Sql/servers/databases/dataMaskingPolicies@2024-11-01-preview' = if (length(dataMaskingRules) > 0) {
  parent: sqlServerName_database
  name: 'Default'
  properties: {
    dataMaskingState: 'Enabled'
    exemptPrincipals: dataMaskingExemptPrincipals
  }
}

resource sqlServerName_databaseName_Default_dataMaskingRules_0_dataMaskingRules_schemaName_dataMaskingRules_tableName_dataMaskingRules_columnName_placeholder 'Microsoft.Sql/servers/databases/dataMaskingPolicies/rules@2024-11-01-preview' = [
  for i in range(0, ((length(dataMaskingRules) > 0) ? length(dataMaskingRules) : 1)): if (length(dataMaskingRules) > 0) {
    name: '${sqlServerName}/${databaseName}/Default/${((length(dataMaskingRules)>0)?concat(dataMaskingRules[i].schemaName,dataMaskingRules[i].tableName,dataMaskingRules[i].columnName):'placeholder')}'
    properties: dataMaskingRules[i]
  }
]
