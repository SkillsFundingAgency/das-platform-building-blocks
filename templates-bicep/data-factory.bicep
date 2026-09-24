param dataFactoryName string

@description('The name of the GitHub account or organisation, eg SkillsFundingAgency')
param gitHubAccountName string = ''

@description('The branch users will merge feature branches into, e.g Master')
param gitHubCollaborationBranch string = ''

@description('The name of the GitHub repository, e.g das-data-factory')
param gitHubRepositoryName string = ''

@description('A GitHub App with the permissions documented below on the repository specified in gitHubRepositoryName')
@metadata({notes: 'Ensure that the GitHub App is Installed and Authorised', permissions: [
'Read access to metadata'
'Read and write access to code and pull requests (contents)'
]})
param gitHubClientId string= ''

@description('The name of the KeyVault Secret')
param gitHubClientSecretKeyVaultName string = ''
param gitHubClientSecretKeyVaultUrl string = ''
param location string

var configureRepo = ((gitHubClientId != '') && (gitHubClientSecretKeyVaultName != ''))
var dataFactoryProperties = (configureRepo ? repoConfiguration : json('{}'))
var repoConfiguration = {
  repoConfiguration: {
    accountName: gitHubAccountName
    collaborationBranch: gitHubCollaborationBranch
    repositoryName: gitHubRepositoryName
    rootFolder: '/'
    type: 'FactoryGitHubConfiguration'
    clientId: gitHubClientId
    clientSecret: {
      byoaSecretAkvUrl: gitHubClientSecretKeyVaultUrl
      byoaSecretName: gitHubClientSecretKeyVaultName
    }
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: dataFactoryProperties
}

output datafactoryManagedIdentity string = reference(
  'Microsoft.DataFactory/factories/${dataFactoryName}',
  '2018-06-01',
  'Full'
).identity.principalId
output datafactoryKeyVaultAccessPolicy array = [
  {
    objectId: reference('Microsoft.DataFactory/factories/${dataFactoryName}', '2018-06-01', 'Full').identity.principalId
    tenantId: reference('Microsoft.DataFactory/factories/${dataFactoryName}', '2018-06-01', 'Full').identity.tenantId
    permissions: {
      secrets: [
        'Get'
        'List'
        'Set'
      ]
    }
  }
]
