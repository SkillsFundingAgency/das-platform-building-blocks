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

# 1.0.7

Start of changelog
