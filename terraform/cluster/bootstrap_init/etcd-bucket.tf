
resource "b2_bucket" "etcd" {
  bucket_name = "${var.cluster}-cluster-etcd"
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

resource "b2_application_key" "etcd" {
  key_name     = "${var.cluster}-etcd"
  capabilities = ["listBuckets", "listAllBucketNames", "listFiles", "writeFiles", "readFiles", "deleteFiles", "readBucketEncryption"]
  bucket_ids   = [b2_bucket.etcd.id]
}
