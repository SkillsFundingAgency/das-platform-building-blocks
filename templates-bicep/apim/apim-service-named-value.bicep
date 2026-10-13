param apimName string
param keyVaultSecretId string
param namedValueName string

resource apimName_namedValue 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  name: '${apimName}/${namedValueName}'
  properties: {
    displayName: namedValueName
    keyVault: {
      secretIdentifier: keyVaultSecretId
    }
    secret: true
  }
}

output namedValueName string = reference(apimName_namedValue.id, '2024-06-01-preview', 'Full').properties.displayName
