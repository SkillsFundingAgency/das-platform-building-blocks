param cosmosDbAccountName string
param cosmosDatabase string
param containerName string
param throughput string = ''
param maxThroughput string = ''

@allowed([
  'GlobalDocumentDB'
  'MongoDB'
])
param cosmosDBType string

var useAutoscaleSettings = (length(maxThroughput) > 0)
var throughputSettings = {
  WithAutoscaling: {
    resource: {
      autoscaleSettings: {
        maxThroughput: maxThroughput
      }
    }
  }
  WithoutAutoscaling: {
    resource: {
      throughput: throughput
    }
  }
}

resource cosmosDbAccountName_cosmosDatabase_containerName_default 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/throughputSettings@2021-05-15' = if (cosmosDBType == 'GlobalDocumentDB') {
  name: '${cosmosDbAccountName}/${cosmosDatabase}/${containerName}/default'
  properties: (useAutoscaleSettings ? throughputSettings.WithAutoscaling : throughputSettings.WithoutAutoscaling)
}

resource Microsoft_DocumentDB_databaseAccounts_mongodbDatabases_collections_throughputSettings_cosmosDbAccountName_cosmosDatabase_containerName_default 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections/throughputSettings@2021-05-15' = if (cosmosDBType == 'MongoDB') {
  name: '${cosmosDbAccountName}/${cosmosDatabase}/${containerName}/default'
  properties: (useAutoscaleSettings ? throughputSettings.WithAutoscaling : throughputSettings.WithoutAutoscaling)
}
