@description('Name of the storage account')
param storageAccountName string

@description('A list of management policy rules. See https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/2019-06-01/storageaccounts/managementpolicies#managementpolicyrule-object for required properties')
param policyRules array = []

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/managementPolicies@2019-06-01' = {
  name: '${storageAccountName}/default'
  properties: {
    policy: {
      rules: policyRules
    }
  }
}
