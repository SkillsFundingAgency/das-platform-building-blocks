param capGBPerMonth int = 10
param storageAccountName string
param enableSensitiveDataDiscovery bool = true
param overrideSubscriptionLevelSettings bool = true
param enableOnUploadMalwareScanning bool = true
param scanResultsEventGridTopicResourceId string = ''

@allowed([
  'blobIndexTags'
  'None'
])
param blobScanResultsOptions string = 'blobIndexTags'

var malwareScanningBase = {
  onUpload: {
    isEnabled: enableOnUploadMalwareScanning
    capGBPerMonth: capGBPerMonth
  }
  blobScanResultsOptions: blobScanResultsOptions
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource current 'Microsoft.Security/DefenderForStorageSettings@2025-06-01' = {
  scope: storageAccount
  name: 'current'
  properties: {
    isEnabled: true
    malwareScanning: (empty(scanResultsEventGridTopicResourceId)
      ? malwareScanningBase
      : union(malwareScanningBase, {
          scanResultsEventGridTopicResourceId: scanResultsEventGridTopicResourceId
        }))
    sensitiveDataDiscovery: {
      isEnabled: enableSensitiveDataDiscovery
    }
    overrideSubscriptionLevelSettings: overrideSubscriptionLevelSettings
  }
}
