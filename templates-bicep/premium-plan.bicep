param premiumPlanName string
param maximumElasticWorkerCount string = '20'

@allowed([
  'North Europe'
  'West Europe'
])
param premiumPlanLocation string = 'West Europe'

@allowed([
  'EP1'
  'EP2'
  'EP3'
])
param skuName string = 'EP1'

resource premiumPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: premiumPlanName
  location: premiumPlanLocation
  sku: {
    name: skuName
    tier: 'ElasticPremium'
  }
  properties: {
    maximumElasticWorkerCount: maximumElasticWorkerCount
  }
}

output PremiumPlanName string = premiumPlan.id
