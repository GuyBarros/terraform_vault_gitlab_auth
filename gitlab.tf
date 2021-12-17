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