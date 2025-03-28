@description('Name of the Route Table')
param routeTableName string

@description('Indicates whether BGP route propagation is disabled')
param disableBgpRoutePropagation bool

@description('Routes to be applied to route table')
param routes array

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: routeTableName
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: routes
  }
}
