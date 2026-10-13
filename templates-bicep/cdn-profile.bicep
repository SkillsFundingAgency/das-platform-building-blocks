@description('Name of Content Delivery Network (CDN) profile')
param cdnProfileName string

@allowed([
  'Premium_Verizon'
  'Custom_Verizon'
  'Standard_Verizon'
  'Standard_Akamai'
  'Standard_Microsoft'
])
param cdnSKU string = 'Standard_Verizon'

resource cdnProfile 'Microsoft.Cdn/profiles@2017-10-12' = {
  name: cdnProfileName
  location: resourceGroup().location
  tags: {}
  sku: {
    name: cdnSKU
  }
}
