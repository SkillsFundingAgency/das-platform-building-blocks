param eventHubNamespaceName string
param eventHubAuthorizationRuleName string
param eventHubAuthorizationRuleRights array = [
  'Listen'
]

resource eventHubNamespaceName_eventHubAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  name: '${eventHubNamespaceName}/${eventHubAuthorizationRuleName}'
  properties: {
    rights: eventHubAuthorizationRuleRights
  }
}

output eventHubAuthorizationRuleId string = eventHubNamespaceName_eventHubAuthorizationRule.id
