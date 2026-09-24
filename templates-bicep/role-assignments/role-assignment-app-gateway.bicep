@allowed([
  'Contributor'
])
param assignmentType string
param principalId string
param resourceName string
param scope string

var Contributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource resourceName_Microsoft_Authorization_principalId_app_gateway 'Microsoft.Network/applicationgateways/providers/roleAssignments@2020-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId),'app-gateway')}'
  properties: {
    roleDefinitionId: Contributor
    principalId: principalId
    scope: scope
  }
}
