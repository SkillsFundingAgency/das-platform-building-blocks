param apimName string
param subscriptionName string

@description('Scope like /products/{productId} or /apis or /apis/{apiId}')
@metadata({
  example: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/das-at-apim-rg/providers/Microsoft.ApiManagement/service/das-at-shared-apim/products/ProductFoo'
})
param subscriptionScope string

resource apimName_subscription 'Microsoft.ApiManagement/service/subscriptions@2019-12-01' = {
  name: '${apimName}/${subscriptionName}'
  properties: {
    scope: subscriptionScope
    displayName: subscriptionName
    state: 'active'
  }
}
