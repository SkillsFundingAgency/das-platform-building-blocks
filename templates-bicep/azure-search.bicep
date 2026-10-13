@description('Service name must only contain lowercase letters, digits or dashes, cannot use dash as the first two or last one characters, cannot contain consecutive dashes, and is limited between 2 and 60 characters in length.')
@minLength(2)
@maxLength(60)
param aiSearchName string

@description('The SKU of the search service you want to create. E.g. free or standard')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param aiSearchSku string = 'basic'

@description('Replicas distribute search workloads across the service. You need 2 or more to support high availability (applies to Basic and Standard only).')
@minValue(1)
@maxValue(12)
param aiSearchReplicaCount int = 1

@description('Partitions allow for scaling of document count as well as faster indexing by sharding your index over multiple Azure Search units.')
@allowed([
  1
  2
  3
  4
  6
  12
])
param aiSearchPartitionCount int = 1

@description('Applicable only for SKUs set to standard3. You can set this property to enable a single, high density partition that allows up to 1000 indexes, which is much higher than the maximum indexes allowed for any other SKU.')
@allowed([
  'default'
])
param aiSearchHostingMode string = 'default'
param aiSearchPublicNetworkAccess string = 'Enabled'

param aiSearchLocation string = resourceGroup().location
param aiSearchDisableLocalAuth bool = true

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aiSearchName
  location: aiSearchLocation
  sku: {
    name: toLower(aiSearchSku)
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    replicaCount: aiSearchReplicaCount
    partitionCount: aiSearchPartitionCount
    hostingMode: aiSearchHostingMode
    publicNetworkAccess: aiSearchPublicNetworkAccess
    disableLocalAuth: aiSearchDisableLocalAuth
  }
}

output aiSearchAdminKey string = listAdminKeys(aiSearchName, '2023-11-01').primaryKey
output aiSearchQueryKey string = listQueryKeys(aiSearchName, '2023-11-01').value[0].key
output aiSearchUrl string = 'https://${aiSearchName}.search.windows.net'
