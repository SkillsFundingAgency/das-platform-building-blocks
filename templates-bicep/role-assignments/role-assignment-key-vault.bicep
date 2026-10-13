@allowed([
  'Key Vault Certificate User'
  'Key Vault Secrets User'
  'Key Vault Crypto User'
])
param assignmentType string
param principalId string
param resourceName string

var Key_Vault_Certificate_User = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/db79e9a7-68ee-4b58-9aeb-b90e7c24fcba'
var Key_Vault_Secrets_User = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'
var Key_Vault_Crypto_User = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/12338af0-0e69-4776-bea7-57ae8d297424'

resource resourceName_Microsoft_Authorization_principalId_resourceName_assignmentType_Key_Vault_Certificate_User_Key_Vault_Certificate_User_assignmentType_Key_Vault_Secrets_User_Key_Vault_Secrets_User_Key_Vault_Crypto_User_key_vault 'Microsoft.KeyVault/vaults/providers/roleAssignments@2020-04-01-preview' = {
  name: '${resourceName}/Microsoft.Authorization/${guid(uniqueString(principalId,resourceName,((assignmentType=='Key Vault Certificate User')?Key_Vault_Certificate_User:((assignmentType=='Key Vault Secrets User')?Key_Vault_Secrets_User:Key_Vault_Crypto_User))),'key-vault')}'
  properties: {
    roleDefinitionId: ((assignmentType == 'Key Vault Certificate User')
      ? Key_Vault_Certificate_User
      : ((assignmentType == 'Key Vault Secrets User') ? Key_Vault_Secrets_User : Key_Vault_Crypto_User))
    principalId: principalId
    scope: resourceId('Microsoft.KeyVault/vaults', resourceName)
  }
}
