param keyVaultName string
param secretName string

@secure()
param secretValue string

resource keyVaultName_secret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}

output keyVaultSecretId string = reference(keyVaultName_secret.id, '2018-02-14', 'Full').properties.secretUriWithVersion
