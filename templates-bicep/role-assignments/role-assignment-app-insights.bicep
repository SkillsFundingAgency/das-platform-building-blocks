param principalId string

@allowed([
  'Monitoring Metrics Publisher'
])
param assignmentType string
param resourceName string

var Monitoring_Metrics_Publisher = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb'

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: resourceName
}

resource resourceName_Monitoring_Metrics_Publisher_principalId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appInsights
  name: guid(uniqueString(resourceName, Monitoring_Metrics_Publisher, principalId))
  properties: {
    roleDefinitionId: Monitoring_Metrics_Publisher
    principalId: principalId
  }
}
