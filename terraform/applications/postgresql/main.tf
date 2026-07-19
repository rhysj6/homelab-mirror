locals {
  hostname = "postgresql.${var.env}.k8s.local"
}

resource "kubernetes_manifest" "cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "postgresql"
      namespace = "cnpg-system"
    }
    spec = {
      instances             = 2
      primaryUpdateStrategy = "unsupervised"
      storage = {
        storageClass = "longhorn-local"
        size         = "100Gi"
      }
      walStorage = {
        size         = "20Gi"
        storageClass = "longhorn-local"
      }
      ephemeralVolumesSizeLimit = {
        shm = "1Gi"
      }
      ephemeralVolumeSource = {
        volumeClaimTemplate = {
          spec = {
            storageClassName = "longhorn-local"
            accessModes      = ["ReadWriteOnce"]
            resources = {
              requests = {
                storage = "1Gi"
              }
            }
          }
        }
      }
      enableSuperuserAccess = true
      monitoring = {
        enablePodMonitor = true
      }
      managed = {
        services = {
          additional = [
            {
              selectorType = "rw"
              serviceTemplate = {
                metadata = {
                  name = "postgresql-rw-loadbalancer"
                  annotations = {
                    "external-dns.alpha.kubernetes.io/hostname" = "${local.hostname}"
                  }
                }
                spec = {
                  type = "LoadBalancer"
                }
              }
            }
          ]
        }
        roles = [for db in var.databases : {
          name = db # Add role for each database
          passwordSecret = {
            name = "${db}-db-credentials"
            key  = "password"
          }
          login = true
        }]
      }
      affinity = {
        nodeSelector = {
          storage_enabled = "true"
        }
      }
      backup = {
        barmanObjectStore = {
          endpointURL     = "https://s3.homelab.example/"
          destinationPath = "s3://${var.env}-postgresql-backup"
          s3Credentials = {
            accessKeyId = {
              name = "minio-backup"
              key  = "access_key"
            }
            secretAccessKey = {
              name = "minio-backup"
              key  = "secret_access_key"
            }
          }
          data = {
            compression = "gzip"
          }
          wal = {
            compression = "gzip"
          }
        }
        retentionPolicy = "45d"
      }
    }
  }
}

resource "kubernetes_manifest" "backup_schedule" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ScheduledBackup"
    metadata = {
      name      = "postgresql-backup"
      namespace = "cnpg-system"
    }
    spec = {
      schedule = "@daily"
      cluster = {
        name = "postgresql"
      }
    }
  }
}

module "database" {
  source = ".//database"

  for_each = var.databases

  name = each.value
  env  = var.env
}

resource "infisical_secret" "db_host" {
  name         = "HOST"
  value        = local.hostname
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/db-creds/${var.env}"
}
