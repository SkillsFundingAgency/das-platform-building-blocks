param cosmosDatabase string
param cosmosDbAccountName string
param containerName string
param pathArray array = []
param partitionKeyArray array = []
param partitionKey string = ''

@allowed([
  'GlobalDocumentDB'
  'MongoDB'
])
param cosmosDBType string

var createIndexPaths = (length(pathArray) > 0)
var createPartitionKeyArray = (length(partitionKeyArray) > 0)
var globalDocumentDBContainerParameters = {
  BaseProperties: {
    id: containerName
  }
  Index: {
    indexingPolicy: {
      indexingMode: 'consistent'
      includedPaths: pathArray
    }
  }
  PartitionKeyArray: {
    partitionKey: {
      paths: partitionKeyArray
      kind: 'Hash'
    }
  }
}
var createPartitionKey = (length(partitionKey) > 0)
var mongoDBContainerParameters = {
  BaseProperties: {
    id: containerName
  }
  PartitionKey: {
    shardKey: {
      '${partitionKey}': 'Hash'
    }
  }
}
var mongoDBProperties = (createPartitionKey
  ? union(mongoDBContainerParameters.BaseProperties, mongoDBContainerParameters.PartitionKey)
  : mongoDBContainerParameters.BaseProperties)
var globalDocumentDBIndexProperties = (createIndexPaths
  ? union(globalDocumentDBContainerParameters.BaseProperties, globalDocumentDBContainerParameters.Index)
  : globalDocumentDBContainerParameters.BaseProperties)
var globalDocumentDBProperties = (createPartitionKeyArray
  ? union(globalDocumentDBIndexProperties, globalDocumentDBContainerParameters.PartitionKeyArray)
  : globalDocumentDBIndexProperties)

resource cosmosDbAccountName_cosmosDatabase_container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-04-15' = if (cosmosDBType == 'GlobalDocumentDB') {
  name: '${cosmosDbAccountName}/${cosmosDatabase}/${containerName}'
  properties: {
    resource: globalDocumentDBProperties
  }
}

resource Microsoft_DocumentDB_databaseAccounts_mongodbDatabases_collections_cosmosDbAccountName_cosmosDatabase_container 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2021-04-15' = if (cosmosDBType == 'MongoDB') {
  name: '${cosmosDbAccountName}/${cosmosDatabase}/${containerName}'
  properties: {
    resource: mongoDBProperties
  }
}
