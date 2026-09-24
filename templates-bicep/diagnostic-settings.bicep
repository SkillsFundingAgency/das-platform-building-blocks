// ARM-backed compatibility module: native Bicep translation remains pending.
param resourceType string

param resourceName string

param diagnosticSettingName string = 'service'

param logAnalyticsWorkspaceResourceId string = ''

param storageAccountResourceId string = ''

param eventHubAuthorizationRuleId string = ''

param eventHubName string = ''

@allowed(['Default', 'AzureDiagnostics', 'Dedicated'])
param logAnalyticsDestinationType string = 'Default'

param logCategoryGroups array = ['allLogs']

param logCategories array = []

param metricCategories array = ['AllMetrics']

module armTemplate '../templates/diagnostic-settings.json' = {
  name: 'diagnostic-settings'
  params: {
    resourceType: resourceType
    resourceName: resourceName
    diagnosticSettingName: diagnosticSettingName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    storageAccountResourceId: storageAccountResourceId
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
    eventHubName: eventHubName
    logAnalyticsDestinationType: logAnalyticsDestinationType
    logCategoryGroups: logCategoryGroups
    logCategories: logCategories
    metricCategories: metricCategories
  }
}
output diagnosticSettingName string = armTemplate.outputs.diagnosticSettingName
output scope string = armTemplate.outputs.scope
