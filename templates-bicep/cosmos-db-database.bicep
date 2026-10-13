param cosmosDatabase string
param cosmosDbAccountName string

@allowed([
  'GlobalDocumentDB'
  'MongoDB'
])
param cosmosDBType string

resource cosmosDbAccountName_CosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = if (cosmosDBType == 'GlobalDocumentDB') {
  name: '${cosmosDbAccountName}/${cosmosDatabase}'
  properties: {
    resource: {
      id: cosmosDatabase
    }
  }
}

resource Microsoft_DocumentDB_databaseAccounts_mongodbDatabases_cosmosDbAccountName_CosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2021-04-15' = if (cosmosDBType == 'MongoDB') {
  name: '${cosmosDbAccountName}/${cosmosDatabase}'
  properties: {
    resource: {
      id: cosmosDatabase
    }
  }
}
