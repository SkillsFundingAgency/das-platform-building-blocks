param userAssignedIdentityName string

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userAssignedIdentityName
  location: resourceGroup().location
}

output tenantId string = userAssignedIdentity.properties.tenantId
output objectId string = userAssignedIdentity.properties.principalId
output clientId string = userAssignedIdentity.properties.clientId
