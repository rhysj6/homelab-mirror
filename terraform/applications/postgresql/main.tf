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
        size         = "10Gi"
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
                    "lbipam.cilium.io/ips" = "${var.loadbalancer_ip}"
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
          name = db.name # Add role for each database
          passwordSecret = {
            name = "${db.name}-db-credentials"
            key  = "password"
          }
          login = true
        }]
      }
      backup = {
        barmanObjectStore = {
          endpointURL     = "https://${local.s3_domain}/"
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
        retentionPolicy = "90d"
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

  for_each = { for db in var.databases : db.name => db }

  name      = each.value.name
  namespace = each.value.namespace
}
