@description('Name of the Azure Front Door profile')
param afdProfileName string

@description('The pricing tier of the Azure Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param afdSKU string = 'Standard_AzureFrontDoor'

resource afdProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: afdProfileName
  location: 'global'
  tags: {}
  sku: {
    name: afdSKU
  }
}

output cdnProfileId string = afdProfile.id
