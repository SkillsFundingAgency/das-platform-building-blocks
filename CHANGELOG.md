# 2.2.13

Added applicaton insights failed request template and get product app insights infomation step

# 2.2.3

Setting default value of WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG to 1

# 2.2.0

Added encrypyion at host property on AKS and AKS node pools

# 2.1.26

Adding the health check property to app-service-v2.json

# 2.1.22

Addition to the role-assignments.json, created a template for Log Analytics role assignment

# 2.1.21

Updated SonarCloud config to use the latest version currently 2.x

# 2.1.1

Removed unused azure-pipelines-templates/deploy/job/arm-deploy.yml and moved placeholder file.

# 2.1.0

templates/cosmos-db.json: Set backupPolicy to Continuous mode (30 days) for Azure Cosmos DB accounts.

# 2.0.5

Migrated from azure-pipelines.yml to .github/workflows/release.yml to avoid PAT token usage.

Addition to the app-build.yml azure-pipelines-template to comment on a Pull Request if the Package Scanning step detects any vulnerabilities.

# 2.0.3

Addition of two azure-pipelines-templates to allow app services including function apps to whitelist and remove the whilist of the pipeline agents.

Needed for automation test suite pipelines.

# 2.0.1

Two new building block templates added to allow pipelines to be whitelisted on a singular or multiple app services and then be removed again.

Addition of the following files -

[appservice-whitelist-ip.yml](https://github.com/SkillsFundingAgency/das-platform-building-blocks/tree/master/azure-pipelines-templates/deploy/step/appservice-whitelist-ip.yml)

[appservice-remove-ip.yml](https://github.com/SkillsFundingAgency/das-platform-building-blocks/tree/master/azure-pipelines-templates/deploy/step/appservice-remove-ip.yml)

# 2.0.0

Breaking change to [generate-config.yml](azure-pipelines-templates/deploy/step/generate-config.yml).  Additional parameters have been added to this step template and changes have been made to the way secrets are handled.  When updating to version 2 or beyond you will need to add EnvironmentName, StorageAccountName & StorageResourceGroup inputs.  You will also need to map any secret variables that are used in config generation in the ConfigurationSecrets variable.  Typically your call to the step template should look something like:
```
- template: azure-pipelines-templates/deploy/step/generate-config.yml@das-platform-building-blocks
  parameters:
    EnvironmentName: $(EnvironmentName)
    ServiceConnection: ${{ parameters.ServiceConnection }}
    SourcePath: $(Pipeline.Workspace)/das-employer-config/Configuration/das-foo-web
    StorageAccountName: $(ConfigurationStorageAccountName)
    StorageAccountResourceGroup: $(SharedEnvResourceGroup)
    ConfigurationSecrets:
      FooSecretConnectionString: $(FooSecretConnectionString)
      BarSecretKey: $(BarSecretKey)
```

# 1.0.8

Start of changelog
