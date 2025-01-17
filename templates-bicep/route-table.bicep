@description('Name of the Route Table')
param routeTableName string

@description('Indicates whether BGP route propagation is disabled')
param disableBgpRoutePropagation bool

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: routeTableName
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
  }
  tags: {}
}
