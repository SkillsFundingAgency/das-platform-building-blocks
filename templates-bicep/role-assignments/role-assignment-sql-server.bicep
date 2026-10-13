param principalId string

@allowed([
  'SqlDbContributor'
])
param assignmentType string
param resourceName string

var SqlDbContributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'

resource resourceName_Microsoft_Authorization_principalId_resourceName_SqlDbContributor 'Microsoft.Sql/servers/providers/roleAssignments@2021-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId,resourceName,last(split(SqlDbContributor,'/'))))}'
  properties: {
    roleDefinitionId: SqlDbContributor
    principalId: principalId
  }
}
