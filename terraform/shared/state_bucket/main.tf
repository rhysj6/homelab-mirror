
resource "b2_bucket" "state_bucket" {
  bucket_name = "homelab-terraform-state"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    mode      = "SSE-B2"
    algorithm = "AES256"
  }

  lifecycle_rules {
    file_name_prefix             = "*"
    days_from_hiding_to_deleting = 30
  }
}

resource "b2_application_key" "cicd_state_bucket_key" {
  key_name     = "cicd-state-bucket-key"
  capabilities = ["listBuckets", "listAllBucketNames", "listFiles", "writeFiles", "readFiles", "deleteFiles", "readBucketEncryption"]
  bucket_ids   = [b2_bucket.state_bucket.id]
}

resource "infisical_secret" "state_access_key" {
  name         = "TFSTATE_ACCESS_KEY"
  value        = b2_application_key.cicd_state_bucket_key.application_key_id
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers"
}


resource "infisical_secret" "state_secret_key" {
  name         = "TFSTATE_SECRET_KEY"
  value        = b2_application_key.cicd_state_bucket_key.application_key
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers"
}
