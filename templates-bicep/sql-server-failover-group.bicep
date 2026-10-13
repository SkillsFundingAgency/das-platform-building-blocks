param failoverGroupName string
param primarySqlServerName string
param secondarySqlServerName string

@description('String array of database resource IDs')
param databases array

@allowed([
  'Manual'
])
param failoverPolicy string = 'Manual'

resource primarySqlServerName_failoverGroup 'Microsoft.Sql/servers/failoverGroups@2015-05-01-preview' = {
  name: toLower('${primarySqlServerName}/${failoverGroupName}')
  properties: {
    readWriteEndpoint: {
      failoverPolicy: failoverPolicy
    }
    partnerServers: [
      {
        id: resourceId('Microsoft.Sql/servers', secondarySqlServerName)
      }
    ]
    databases: databases
  }
}
