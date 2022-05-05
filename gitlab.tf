terraform{
    required_providers{
        gitlab = {
            source  = "gitlabhq/gitlab"
        }
    }
}

data "gitlab_project" "vault" {
  id = var.gitlab_project_id
}


resource "gitlab_project_variable" "vault_server_url" {
  project   = data.gitlab_project.vault.id
  key       = "VAULT_SERVER_URL"
  value     = var.gitlab_vault_server_url
  protected = false
}

resource "gitlab_project_variable" "vault_auth_role" {
  project   = data.gitlab_project.vault.id
  key       = "VAULT_AUTH_ROLE"
  value     = vault_jwt_auth_backend_role.pipeline.role_name
  protected = false
}

resource "gitlab_project_variable" "vault_auth_path" {
  project   = data.gitlab_project.vault.id
  key       = "VAULT_AUTH_PATH"
  value     = vault_jwt_auth_backend.gitlab.path
  protected = false
}
