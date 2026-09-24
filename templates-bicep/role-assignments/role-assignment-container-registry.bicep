@allowed([
  'AcrPull'
])
param assignmentType string
param resourceName string
param principalId string

var AcrPull = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource resourceName_Microsoft_Authorization_principalId 'Microsoft.ContainerRegistry/registries/providers/roleAssignments@2018-09-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId))}'
  properties: {
    roleDefinitionId: AcrPull
    principalId: principalId
  }
}
