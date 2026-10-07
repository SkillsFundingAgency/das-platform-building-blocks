param principalId string

@allowed([
  'DeveloperPortal'
])
param assignmentType string
param resourceName string

var DeveloperPortal = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b68e4721-7391-4853-911c-34855e9c2cec'

resource resourceName_Microsoft_Authorization_principalId 'Microsoft.ApiManagement/service/providers/roleAssignments@2018-09-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId))}'
  properties: {
    roleDefinitionId: DeveloperPortal
    principalId: principalId
  }
}
