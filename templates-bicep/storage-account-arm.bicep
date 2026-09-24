@description('Name of the storage account')
param storageAccountName string

@description('Recommendation: If using to store backup data, choose the paired region for resilience')
param storageAccountLocation string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Premium_LRS'
])
param accountType string = 'Standard_LRS'

@description('This setting is required if using BlobStorage as the storageKind, otherwise can be left blank')
@allowed([
  'Hot'
  'Cool'
  ''
])
param accessTier string = ''

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
])
param storageKind string = 'Storage'

@description('Allow or disallow public access to all blobs or containers in the storage account. Individual containers\' access levels must also be set to Blob/Container to be accessible anonymously.')
param allowBlobPublicAccess bool = false
param allowSharedKeyAccess bool = true

@description('A list of subnet resource ids.')
param subnetResourceIdList array = []

@description('A list of allowed IPs')
param allowedIpAddressesList array = []

@allowed([
  'False'
  'True'
])
param enableCors string = 'False'

@description('Minimum version of TLS required to access data in storage accounts')
@metadata({ displayName: 'Minimum TLS Version' })
@allowed([
  'TLS1_0'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'
param allowedHeaders array = [
  '*'
]
param allowedOrigins array = [
  '*'
]
param maxAgeInSeconds string = '3600'
param allowedMethods array = [
  'GET'
]
param exposedHeaders array = [
  '*'
]

@description('Allow Azure Services access to the KeyVault')
param allowAzureServices bool = false

var virtualNetworkRulesArray = [
    for j in range(0, ((length(subnetResourceIdList) > 0) ? length(subnetResourceIdList) : 1)): {
      id: ((length(subnetResourceIdList) > 0) ? subnetResourceIdList[j] : json('null'))
      action: 'Allow'
    }
  ]
var virtualNetworkRules = {
  virtualNetworkRules: virtualNetworkRulesArray
}
var ipRulesArray = [
    for j in range(0, ((length(allowedIpAddressesList) > 0) ? length(allowedIpAddressesList) : 1)): {
      value: ((length(allowedIpAddressesList) > 0) ? allowedIpAddressesList[j] : json('null'))
      action: 'Allow'
    }
  ]
var ipRules = {
  ipRules: ipRulesArray
}
var defaultNetworkAclBypass = 'Logging, Metrics'
var networkAclObject = {
  bypass: (allowAzureServices ? '${defaultNetworkAclBypass}, AzureServices' : defaultNetworkAclBypass)
  virtualNetworkRules: ((length(subnetResourceIdList) > 0) ? virtualNetworkRules.virtualNetworkRules : json('null'))
  ipRules: ((length(allowedIpAddressesList) > 0) ? ipRules.ipRules : json('null'))
  defaultAction: 'Deny'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: storageAccountName
  location: storageAccountLocation
  sku: {
    name: accountType
  }
  kind: storageKind
  tags: {}
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: (empty(accessTier) ? json('null') : accessTier)
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    supportsHttpsTrafficOnly: true
    networkAcls: (((length(subnetResourceIdList) > 0) || (length(allowedIpAddressesList) > 0))
      ? networkAclObject
      : json('null'))
    minimumTlsVersion: minimumTlsVersion
  }
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2018-11-01' = if (enableCors == 'True') {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: allowedOrigins
          allowedMethods: allowedMethods
          maxAgeInSeconds: maxAgeInSeconds
          exposedHeaders: exposedHeaders
          allowedHeaders: allowedHeaders
        }
      ]
    }
  }
}

output storageKey string = listKeys(storageAccount.id, providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value
output storageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id,providers('Microsoft.Storage','storageAccounts').apiVersions[0]).keys[0].value};EndpointSuffix=core.windows.net'
output storagePrimaryEndpointsBlob string = reference(storageAccount.id, '2021-09-01').primaryEndpoints.blob
output storagePrimaryEndpointsWeb string = ((storageKind == 'StorageV2')
  ? reference(storageAccount.id, '2021-09-01').primaryEndpoints.web
  : '')
output storageResourceId string = storageAccount.id
