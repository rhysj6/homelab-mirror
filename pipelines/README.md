# Pipelines
I use Azure DevOps pipelines to run the CI/CD pipelines because it is very powerful and integrates well with github. Because I want to make my repository as open as I could whilst maintaining security, I have generally aimed to obfiscate any sensitive information such as domain names, so I needed to make my pipeline logs private, however, I wanted to have the pipeline definitions public so that anyone can see how the pipelines are configured and how they work, Azure DevOps allows you to do this whilst also making the statuses of the pipelines public, so anyone can see the status of the pipelines but not the logs that contain sensitive information.

# Folder Structure

## module
Because Azure DevOps pipelines are not automatically detected, I have created a terraform module that reads the files in the relevant folders and adds each pipeline.

## provisioning.yml
This is a pipeline that automatically applies the terraform module to provision the pipelines, it is triggered on any changes to this folder, so if a new pipeline is added or an existing pipeline is deleted, the pipelines will be updated automatically.

## templates
Azure DevOps pipelines have a powerful templating system that allows you to reuse code across multiple pipelines. I have created a set of templates that are used by all the pipelines to make them more maintainable. The current templates are:
- **discord-notification.yml**: This template is used to send notifications to a discord channel, it is used by the other templates when I want to have it notify me for example if a manual approval is required.
- **module-change-detection.yml**: This template is used to detect changes when a PR is created, it runs a plan with no state refresh to see if there are changes that will need to be applied to the cluster. It writes a comment on the github PR saying that the module has changed so that I am aware.
- **apply-module.yml**: This template is used to apply the module changes, it runs a plan and then if there are changes, it notifies the discord channel and waits for a manual approval before applying the changes.

# pipeline folders
Any other folders in this directory contain the pipelines, the structure of these folders will roughly follow the structure of the rest of the repository, so for example, there will be a folder applications which will have pipelines for each cluster.