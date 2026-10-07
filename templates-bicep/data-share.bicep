param dataShareName string

resource dataShare 'Microsoft.DataShare/accounts@2020-09-01' = {
  name: dataShareName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
}

output managedServiceIdentityId string = reference(dataShareName, '2020-09-01', 'Full').identity.principalId
