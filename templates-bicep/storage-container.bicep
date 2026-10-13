@description('Name of the storage account the container belongs to')
param storageAccountName string

@description('Name of the container')
param containerName string

@description('Level of public accessibility of the created container')
@allowed([
  'Container'
  'Blob'
  'None'
])
param publicAccess string = 'None'

resource storageAccountName_default_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-04-01' = {
  name: '${storageAccountName}/default/${containerName}'
  properties: {
    publicAccess: publicAccess
  }
}
