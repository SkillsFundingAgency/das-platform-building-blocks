param redisCacheName string
param redisCacheSKU string = 'Basic'
param redisCacheFamily string = 'C'
param redisCacheCapacity int = 1
param enableNonSslPort bool = false
param minimumTlsVersion string = '1.2'

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

resource redisCache 'Microsoft.Cache/Redis@2023-08-01' = {
  name: redisCacheName
  location: resourceGroup().location
  properties: {
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: minimumTlsVersion
    publicNetworkAccess: publicNetworkAccess
    sku: {
      capacity: redisCacheCapacity
      family: redisCacheFamily
      name: redisCacheSKU
    }
  }
}

output PrimaryKey string = listKeys(redisCache.id, '2023-08-01').primaryKey
output SecondaryKey string = listKeys(redisCache.id, '2023-08-01').secondaryKey
output PrimaryConnectionString string = '${redisCacheName}.redis.cache.windows.net:6380,password=${listKeys(redisCache.id,'2023-08-01').primaryKey},ssl=True,abortConnect=False'
output SecondaryConnectionString string = '${redisCacheName}.redis.cache.windows.net:6380,password=${listKeys(redisCache.id,'2023-08-01').secondaryKey},ssl=True,abortConnect=False'
