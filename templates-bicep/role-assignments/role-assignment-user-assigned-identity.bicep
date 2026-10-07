@allowed([
  'ManagedIdentityOperatorRole'
])
param assignmentType string
param principalId string
param resourceName string
param scope string

var ManagedIdentityOperatorRole = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830'

resource resourceName_Microsoft_Authorization_principalId_user_assigned_identity 'Microsoft.ManagedIdentity/userAssignedIdentities/providers/roleAssignments@2020-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId),'user-assigned-identity')}'
  properties: {
    roleDefinitionId: ManagedIdentityOperatorRole
    principalId: principalId
    scope: scope
  }
}
