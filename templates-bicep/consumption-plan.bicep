param consumptionPlanName string

@allowed([
  'North Europe'
  'West Europe'
])
param consumptionPlanLocation string = 'West Europe'

var sku = {
  name: 'Y1'
  tier: 'Dynamic'
}
var properties = {
  name: consumptionPlanName
}

resource consumptionPlan 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: consumptionPlanName
  location: consumptionPlanLocation
  sku: sku
  properties: properties
}

output ConsumptionPlanName string = consumptionPlan.id
