# Applications Folder

This folder contains the configurations and modules for deploying various applications. The structure is designed to support both simple, single-cluster applications and more complex, multi-cluster applications.

## Folder Structure

Each application should follow one of the following patterns based on its complexity:

### Complex Applications
For applications that span multiple clusters or require post-deployment configuration:
```
applications/
  <application-name>/
    module/       # Reusable Terraform modules for the application
    env/          # Environment-specific configurations (e.g., dev, prod, test)
      <environment-name>/
        main.tf
        providers.tf # This would contain things like the rancher kubeconfig module
    config/       # Configuration applied after the application is deployed
```
This also supports things like being able to easily deploy a test version to make and test changes on before deploying to the production 

### Simple Applications
For single-cluster, single-environment applications:
```
applications/
  <application-name>/
    main.tf       # Main Terraform configuration
    variables.tf  # Input variables for the application
    outputs.tf    # Outputs for the application
    providers.tf  # Provider configurations
```

## Default State Key for Environments

The default state key for environments should follow the pattern:

```
applications/<application_name>/env/<environment_name>.tfstate
```

For example, for the `authentik` application in the `redcliff` environment, the state key would be:

```
applications/authentik/env/redcliff.tfstate
```

## Guidelines
- Use the `module` folder for reusable logic that can be shared across environments.
- Place environment-specific overrides in the `env` folder.
- Store post-deployment configurations in the `config` folder.
- For simple applications, keep all configurations in a single module to reduce complexity.
