@description('Name of the Route Table')
param routeTableName string

@description('Indicates whether BGP route propagation is disabled')
param disableBgpRoutePropagation bool

@description('Array of routes to be added to route table')
param routeTableRoutes array = []

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: routeTableName
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: routeTableRoutes
  }
  tags: {}
}
