@description('The name of the automation account')
param automationAccountName string

@description('The pricing tier of the automation account')
@allowed([
  'Free'
  'Basic'
])
param skuName string = 'Basic'

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: skuName
    }
  }
}

output managedServiceIdentityId string = reference(automationAccount.id, '2021-06-22', 'Full').identity.principalId
