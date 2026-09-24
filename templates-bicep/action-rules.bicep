param actionRuleName string

@metadata({
  example1: [
    '/subscriptions/111a1aa11-1111-111a-a11a-11a111aaa1/resourceGroups/my-rg'
  ]
})
param actionRuleScopes array
param actionRuleEffectiveFrom string = '1900-01-01T00:00:00'
param actionRuleTimeZone string = 'GMT Standard Time'

@metadata({
  schema: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?tabs=json#recurrence'
})
param actionRuleRecurrence array = []

@metadata({
  schema: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?tabs=json#condition'
})
param actionRuleConditions array = []

resource actionRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: actionRuleName
  location: 'Global'
  properties: {
    scopes: actionRuleScopes
    schedule: {
      effectiveFrom: actionRuleEffectiveFrom
      timeZone: actionRuleTimeZone
      recurrences: actionRuleRecurrence
    }
    conditions: actionRuleConditions
    enabled: true
    actions: [
      {
        actionType: 'RemoveAllActionGroups'
      }
    ]
  }
}
