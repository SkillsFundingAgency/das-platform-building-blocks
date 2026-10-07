param sqlServerName string
param elasticPoolName string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param elasticPoolEdition string = 'Standard'
param elasticPoolDtu int = 50
param elasticPoolMinDtu int = 0
param elasticPoolMaxDtu int = 20

resource sqlServerName_elasticPool 'Microsoft.Sql/servers/elasticpools@2014-04-01' = {
  name: '${sqlServerName}/${elasticPoolName}'
  location: resourceGroup().location
  properties: {
    edition: elasticPoolEdition
    dtu: elasticPoolDtu
    databaseDtuMin: elasticPoolMinDtu
    databaseDtuMax: elasticPoolMaxDtu
  }
}
