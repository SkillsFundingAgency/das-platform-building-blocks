param principalId string

@allowed([
  'Log Analytics Reader'
])
param assignmentType string
param resourceName string

var Log_Analytics_Reader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/73c42c96-874c-492b-b04d-ab87d138a893'

resource resourceName_Microsoft_Authorization_principalId_log_analytics_workspace 'Microsoft.OperationalInsights/workspaces/providers/roleAssignments@2020-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId),'log-analytics-workspace')}'
  properties: {
    roleDefinitionId: Log_Analytics_Reader
    principalId: principalId
    scope: resourceId('Microsoft.OperationalInsights/workspaces', resourceName)
  }
}
