param appServicePlanName string

@allowed([
  'North Europe'
  'West Europe'
  'UK South'
])
param aspLocation string = 'West Europe'
param aseHostingEnvironmentName string = ''
param aseResourceGroup string = ''

@allowed([
  '0'
  '1'
  '2'
  '3'
])
param aspSize string
param aspInstances int

@allowed([
  'Free'
  'Basic'
  'Standard'
  'Premium'
  'PremiumV2'
  'PremiumV3'
  'Premium0V3'
])
param nonASETier string = 'Standard'

var deployToASE = (length(aseHostingEnvironmentName) > 0)
var aspResourceProperties = {
  WithASE: {
    name: appServicePlanName
    hostingEnvironmentProfile: {
      id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${aseResourceGroup}/providers/Microsoft.Web/hostingEnvironments/${aseHostingEnvironmentName}'
    }
  }
  WithoutASE: {
    name: appServicePlanName
  }
}
var aspSkuName = concat(
  take(nonASETier, 1),
  aspSize,
  ((nonASETier == 'PremiumV2') ? 'v2' : ''),
  (((nonASETier == 'PremiumV3') || (nonASETier == 'Premium0V3')) ? 'v3' : '')
)
var defaultAppServicePlanSKUs = {
  NonASE: {
    name: aspSkuName
    tier: nonASETier
    size: aspSkuName
    family: take(nonASETier, 1)
    capacity: aspInstances
  }
  Isolated: {
    name: 'I${aspSize}'
    tier: 'Isolated'
    size: 'I${aspSize}'
    family: 'I'
    capacity: aspInstances
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: appServicePlanName
  location: aspLocation
  properties: (deployToASE ? aspResourceProperties.WithASE : aspResourceProperties.WithoutASE)
  sku: (deployToASE ? defaultAppServicePlanSKUs.Isolated : defaultAppServicePlanSKUs.NonASE)
}

output appServicePlanId string = appServicePlan.id
