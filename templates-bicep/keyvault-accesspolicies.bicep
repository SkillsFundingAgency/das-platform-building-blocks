param keyVaultName string

@metadata({
  objectSchema: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/2018-02-14/vaults/accesspolicies#AccessPolicyEntry'
})
param accessPolicies array

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2018-02-14' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: accessPolicies
  }
}
