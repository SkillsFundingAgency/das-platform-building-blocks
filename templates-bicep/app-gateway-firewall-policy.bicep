@description('Must be only lowercase alphanumeric characters')
param firewallPolicyName string
param disabledRuleGroups array = []
param exclusions array = []
param fileUploadLimitInMb int = 100
param firewallCustomRules array = []

@allowed([
  'Detection'
  'Prevention'
])
param firewallMode string = 'Prevention'
param maxRequestBodySizeInKb int = 128
param requestBodyCheck bool = true
param ruleSetVersion string = '3.1'

@allowed([
  'Enabled'
  'Disabled'
])
param state string = 'Enabled'

resource firewallPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-06-01' = {
  name: firewallPolicyName
  location: resourceGroup().location
  properties: {
    policySettings: {
      state: state
      mode: firewallMode
      requestBodyCheck: requestBodyCheck
      maxRequestBodySizeInKb: maxRequestBodySizeInKb
      fileUploadLimitInMb: fileUploadLimitInMb
    }
    customRules: firewallCustomRules
    managedRules: {
      exclusions: exclusions
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: ruleSetVersion
          ruleGroupOverrides: disabledRuleGroups
        }
      ]
    }
  }
}
