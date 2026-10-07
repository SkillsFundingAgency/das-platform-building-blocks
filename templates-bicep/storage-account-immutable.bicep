param storageAccountName string
param storageAccountLocation string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param accountType string = 'Standard_LRS'

@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Cool'

@allowed([
  'Disabled'
  'Unlocked'
  'Locked'
])
param immutabilityPolicyState string = 'Disabled'

@minValue(1)
@maxValue(146000)
param immutabilityPeriodSinceCreationInDays int = 365
param allowSharedKeyAccess bool = true
param allowAzureServices bool = true

@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Deny'
param subnetResourceIdList array = []
param allowedIpAddressesList array = []

@allowed([
  'TLS1_0'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

var immutableStorageConfig = {
  enabled: true
  immutabilityPolicy: {
    immutabilityPeriodSinceCreationInDays: immutabilityPeriodSinceCreationInDays
    allowProtectedAppendWrites: true
    state: immutabilityPolicyState
  }
}
var defaultNetworkAclBypass = 'Logging, Metrics'
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
var networkAclObject = {
  bypass: (allowAzureServices ? '${defaultNetworkAclBypass}, AzureServices' : defaultNetworkAclBypass)
  virtualNetworkRules: ((length(subnetResourceIdList) > 0) ? virtualNetworkRules.virtualNetworkRules : json('null'))
  ipRules: ((length(allowedIpAddressesList) > 0) ? ipRules.ipRules : json('null'))
  defaultAction: networkAclsDefaultAction
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: storageAccountLocation
  tags: {}
  sku: {
    name: accountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: false
    allowSharedKeyAccess: allowSharedKeyAccess
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: minimumTlsVersion
    networkAcls: networkAclObject
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
    immutableStorageWithVersioning: immutableStorageConfig
  }
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
  }
}

output storageAccountName string = storageAccountName
output storageResourceId string = storageAccount.id
output immutabilityPolicyState string = immutabilityPolicyState
