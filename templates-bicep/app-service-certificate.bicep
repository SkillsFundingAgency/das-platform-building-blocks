param keyVaultCertificateName string
param keyVaultName string
param keyVaultResourceGroup string
param serverFarmId string = ''

var includeServerFarmId = (length(serverFarmId) > 0)
var certificateResourceProperties = {
  withServerFarmId: {
    keyVaultId: resourceId(keyVaultResourceGroup, 'Microsoft.KeyVault/vaults', keyVaultName)
    keyVaultSecretName: keyVaultCertificateName
    serverFarmId: serverFarmId
  }
  withoutServerFarmId: {
    keyVaultId: resourceId(keyVaultResourceGroup, 'Microsoft.KeyVault/vaults', keyVaultName)
    keyVaultSecretName: keyVaultCertificateName
  }
}

resource keyVaultCertificate 'Microsoft.Web/certificates@2016-03-01' = {
  name: keyVaultCertificateName
  location: resourceGroup().location
  properties: (includeServerFarmId
    ? certificateResourceProperties.withServerFarmId
    : certificateResourceProperties.withoutServerFarmId)
}

output certificateThumbprint string = reference(keyVaultCertificate.id, '2016-03-01').Thumbprint
