param apimName string
param productResourceName string
param productDisplayName string
param productDescription string
param productSubscriptionRequired bool
param productSubscriptionsLimit string = ''
param productApprovalRequired bool
param productState string

var productBaseProperties = {
  displayName: productDisplayName
  description: productDescription
  subscriptionRequired: productSubscriptionRequired
  approvalRequired: productApprovalRequired
  state: productState
}

resource apimName_productResource 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: '${apimName}/${productResourceName}'
  properties: (empty(productSubscriptionsLimit)
    ? productBaseProperties
    : union(productBaseProperties, {
        subscriptionsLimit: int(productSubscriptionsLimit)
      }))
}
