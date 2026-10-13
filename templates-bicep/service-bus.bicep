@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('The messaging tier for service Bus namespace')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSku string = 'Standard'

@description('Names of service bus queues to create within the namespace')
param serviceBusQueues array = []

@description('Log analytics workspace to send logs to (leave blank to disable)')
param logAnalyticsWorkspaceName string = ''
param logAnalyticsWorkspaceResourceGroupName string = ''

var deployQueues = (length(serviceBusQueues) > 0)
var logDiagnosticSettingsEnabled = (!empty(logAnalyticsWorkspaceName))
var logAnalyticsWorkspaceResourceId = resourceId(
  logAnalyticsWorkspaceResourceGroupName,
  'Microsoft.OperationalInsights/workspaces',
  logAnalyticsWorkspaceName
)

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: serviceBusNamespaceName
  properties: {}
  location: resourceGroup().location
  sku: {
    name: serviceBusSku
  }
}

resource serviceBusNamespaceName_ReadWrite 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2017-04-01' = {
  parent: serviceBusNamespace
  name: 'ReadWrite'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
}

resource serviceBusNamespaceName_Read 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2017-04-01' = {
  parent: serviceBusNamespace
  name: 'Read'
  properties: {
    rights: [
      'Listen'
    ]
  }
  dependsOn: [
    serviceBusNamespaceName_ReadWrite
  ]
}

resource serviceBusNamespaceName_Microsoft_Insights_service 'Microsoft.ServiceBus/namespaces/providers/diagnosticSettings@2021-05-01-preview' = if (logDiagnosticSettingsEnabled) {
  name: '${serviceBusNamespaceName}/Microsoft.Insights/service'
  location: resourceGroup().location
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'ApplicationMetricsLogs'
        enabled: true
      }
      {
        category: 'DiagnosticErrorLogs'
        enabled: true
      }
      {
        category: 'OperationalLogs'
        enabled: true
      }
      {
        category: 'RuntimeAuditLogs'
        enabled: true
      }
      {
        category: 'VNetAndIPFilteringLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
  dependsOn: [
    serviceBusNamespace
  ]
}

resource serviceBusNamespaceName_deployQueues_serviceBusQueues_placeholder 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = [
  for i in range(0, (deployQueues ? length(serviceBusQueues) : 1)): if (deployQueues) {
    name: '${serviceBusNamespaceName}/${(deployQueues?serviceBusQueues[i]:'placeholder')}'
    properties: {}
    dependsOn: [
      serviceBusNamespace
    ]
  }
]

output ServiceBusEndpoint string = listkeys(serviceBusNamespaceName_ReadWrite.id, '2017-04-01').primaryConnectionString
output ServiceBusEndpointReadOnly string = listkeys(serviceBusNamespaceName_Read.id, '2017-04-01').primaryConnectionString
