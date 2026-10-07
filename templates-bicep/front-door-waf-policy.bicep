@description('The name of the Web Application Firewall Policy')
param policyName string

@description('Describes if the policy is in enabled or disabled state. Defaults to Enabled if not specified. - Disabled or Enabled')
@allowed([
  'Enabled'
  'Disabled'
])
param enabledState string = 'Enabled'

@description('Describes if it is in detection mode or prevention mode at policy level. - Prevention or Detection')
@allowed([
  'Prevention'
  'Detection'
])
param mode string = 'Prevention'

@description('Defines the version of the rule set to use')
param ruleSetVersion string = '1.0'

@description('Defines the rule group overrides to apply to the rule set. Pass an array of ManagedRuleGroupOverride objects (https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2019-03-01/frontdoorwebapplicationfirewallpolicies#managedrulegroupoverride-object).')
param ruleGroupOverrides array = []

resource policy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2019-03-01' = {
  name: policyName
  location: 'global'
  properties: {
    policySettings: {
      enabledState: enabledState
      mode: mode
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'DefaultRuleSet'
          ruleSetVersion: ruleSetVersion
          ruleGroupOverrides: ruleGroupOverrides
        }
      ]
    }
  }
}
