@description('Name of the Service Bus Namespace that will be configured with the authorization rule.')
param serviceBusNamespaceName string

@description('Name of the new Service Bus authorisation rule.')
param serviceBusAuthRuleName string

@description('Array of the rights required, containing one or more of; Manage, Listen, Send.')
param serviceBusAuthRuleRights array = [
  'Listen'
]

resource serviceBusNamespaceName_serviceBusAuthRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2017-04-01' = {
  name: '${serviceBusNamespaceName}/${serviceBusAuthRuleName}'
  properties: {
    rights: serviceBusAuthRuleRights
  }
}

output ServiceBusConnectionString string = listKeys(serviceBusNamespaceName_serviceBusAuthRule.id, '2017-04-01').primaryConnectionString
