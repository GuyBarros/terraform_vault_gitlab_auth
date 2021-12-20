# terraform_vault_gitlab_auth
quick terraform job to configure Gitlab JWT Auth


## Pre requirements
to use this terraform code you will need access  to gitlab(the free,gtilab.com version is fine) and Vault (the OSS version is fine but I used HCP Vault).

you will need to generate a gitlab [OAuth2 token or project/personal access token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html)


### terraform provider
this code needs that the Vault and JWT provider access be set as enviroment variables:
```bash
export GITLAB_TOKEN=<GITLAB_TOKEN>
export VAULT_TOKEN=<VAULT_TOKEN>
export VAULT_ADDR=https://<VAULT_ADDRESS>:8200

```
### terraform variables
this project has one manatory variable *gitlab_project_id* which is the name of the project you want to enable the JWT Auth Method for.
this can be set by creating a terraform.tfvars file:

```text
gitlab_project_id = "guydemos/demostack"
```

## running the code

```bash
terraform init
terraform plan
terraform apply
```


## Entities & JWT Auth
JWT Auth Method creates entities based on the *user_claim* configured at the Vault JWT Auth Method role; These can be a field from the [JWT token itself](https://docs.gitlab.com/ee/ci/examples/authenticating-with-hashicorp-vault/index.html#how-it-works)

depending on how the user_claim is configured, it is also possible to use the bound_claim to specify the match paramaters that allow authentication.






## Notice
this currently is for reference , PRs welcomed.