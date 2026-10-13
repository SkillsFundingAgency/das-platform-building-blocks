@description('Name of the storage account')
param storageAccountName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Premium_LRS'
])
param accountType string = 'Standard_LRS'

resource storageAccount 'Microsoft.ClassicStorage/storageAccounts@2016-11-01' = {
  name: storageAccountName
  location: resourceGroup().location
  properties: {
    accountType: accountType
  }
}

output StorageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id,'2016-11-01').primaryKey}'
