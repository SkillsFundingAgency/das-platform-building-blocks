param apimName string
param productResourceName string
param productGroupIds array

resource apimName_productResourceName_productGroupIds 'Microsoft.ApiManagement/service/products/groups@2019-12-01' = [
  for item in productGroupIds: {
    name: '${apimName}/${productResourceName}/${item}'
    properties: {}
  }
]
