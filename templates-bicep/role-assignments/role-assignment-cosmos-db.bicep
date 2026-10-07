@allowed([
  'CosmosReader'
  'CosmosContributor'
])
param assignmentType string
param resourceName string
param principalId string

var CosmosReader = resourceId(
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions',
  resourceName,
  '00000000-0000-0000-0000-000000000001'
)
var CosmosContributor = resourceId(
  'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions',
  resourceName,
  '00000000-0000-0000-0000-000000000002'
)

resource resourceName_principalId 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-10-15' = {
  name: '${resourceName}/${guid(uniqueString(principalId))}'
  properties: {
    roleDefinitionId: ((assignmentType == 'CosmosReader') ? CosmosReader : CosmosContributor)
    principalId: principalId
    scope: resourceId('Microsoft.DocumentDB/databaseAccounts', resourceName)
  }
}
