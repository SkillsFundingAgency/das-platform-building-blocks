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
