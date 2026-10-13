param principalId string
param assignmentType string = 'Contributor'
param resourceName string

var Contributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource resourceName_Microsoft_Authorization_resourceName_assignmentType_principalId 'Microsoft.DataShare/accounts/providers/roleAssignments@2021-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(resourceName,assignmentType,principalId))}'
  properties: {
    roleDefinitionId: Contributor
    principalId: principalId
    scope: resourceId('Microsoft.DataShare/accounts', resourceName)
  }
}
