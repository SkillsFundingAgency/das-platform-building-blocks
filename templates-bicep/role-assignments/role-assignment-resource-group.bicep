@allowed([
  'Contributor'
  'Reader'
  'VirtualMachineContributor'
])
param assignmentType string
param principalId string

var Contributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var Reader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
var VirtualMachineContributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

resource principalId_assignmentType 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uniqueString(principalId), assignmentType)
  properties: {
    roleDefinitionId: ((assignmentType == 'Contributor')
      ? Contributor
      : ((assignmentType == 'Reader') ? Reader : VirtualMachineContributor))
    principalId: principalId
    scope: resourceGroup().id
  }
}
