data "vault_namespace" "current" {}

#Policy
resource "vault_policy" "pipeline-policy" {
  name = "pipeline-policy"

  policy = <<EOT
path "kv/test" {
  capabilities = ["read"]
}

path "kv/data/test" {
  capabilities = ["read"]
}

path "${vault_mount.kvv2.path}" {
  capabilities = ["read"]
}

path "${vault_mount.kvv2.path}/data/${vault_kv_secret_v2.example.name}" {
  capabilities = ["read"]
}
EOT
}

# JWT Auth Mount
resource "vault_jwt_auth_backend" "gitlab" {
  description  = "JWT auth backend for Gitlab-CI pipeline"
  path         = "gitlab_jwt"
  oidc_discovery_url     = "https://gitlab.com"
  default_role = "generic"
  tune {
    listing_visibility = "unauth"
    default_lease_ttl  = var.gitlab_default_lease_ttl
    max_lease_ttl      = var.gitlab_max_lease_ttl
    token_type         = var.gitlab_token_type
  }
}

# JWT Auth Role
resource "vault_jwt_auth_backend_role" "pipeline" {
  backend   = vault_jwt_auth_backend.gitlab.path
  role_type = "jwt"

  role_name      = "app-pipeline"
  token_policies = ["default", "pipeline-policy"]

  bound_audiences=["https://gitlab.com" ]

  bound_claims = {
    iss         = "gitlab.com,https://gitlab.com"
    project_id = data.gitlab_project.vault.id
    ref        = "main"
    ref_type   = "branch"
  }

  user_claim = "project_id"

  claim_mappings = {
    "project_id"            = "project_id"
    "namespace_id"          = "namespace_id"
    "namespace_path"        = "namespace_path"
    "project_path"          = "project_path"
    "user_id"               = "user_id"
    "user_login"            = "user_login"
    "user_email"            = "user_email"
    "pipeline_id"           = "pipeline_id"
    "pipeline_source"       = "pipeline_source"
    "job_id"                = "job_id"
    "ref"                   = "ref"
    "ref_type"              = "ref_type"
    "ref_protected"         = "ref_protected"
    "environment"           = "environment"
    "environment_protected" = "environment_protected"
  }
}

# JWT Auth Role
resource "vault_jwt_auth_backend_role" "generic" {
  backend   = vault_jwt_auth_backend.gitlab.path
  role_type = "jwt"

  role_name      = "generic"
  token_policies = ["default", "pipeline-policy"]

  bound_audiences=["https://gitlab.com" ]

  bound_claims = {
    iss         = "gitlab.com,https://gitlab.com"
    project_id = data.gitlab_project.vault.id
    ref        = "main"
    ref_type   = "branch"
  }

  user_claim = "project_id"
}

# Secret Mount
resource "vault_mount" "secret-mount" {
  path        = "kv"
  type        = "kv-v2"
  description = "KV Secrets engine"
}

# Secret Vaulet
resource "vault_generic_secret" "lob-secret" {
  path = "kv/test"

  data_json = <<EOT
{
    "foo": "This is my super secure secret!"
}
EOT

  depends_on = [vault_mount.secret-mount]
}



resource "vault_mount" "kvv2" {
  path        = "gitlab-example"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  mount                      = vault_mount.kvv2.path
  name                       = "secret"
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    zip       = "zap",
    foo       = "bar"
  }
  )
  custom_metadata {
    max_versions = 5
    data = {
      foo = "vault@example.com",
      bar = "12345"
    }
  }
}