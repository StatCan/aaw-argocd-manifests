local image = "k8scc01covidacr.azurecr.io/minio-credential-injector:ce0cdc26094b2dcd6f47ab84011c50f820bba8b5";

# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));

local vault_addr_ext = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      "https://vault.aaw.cloud.statcan.ca"
else
      "https://vault.aaw-dev.cloud.statcan.ca"
;

{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "minio-credential-injector",
    "namespace": "daaas-system",
    "labels": {
      "apps.kubernetes.io/name": "minio-credential-injector"
    }
  },
  "spec": {
    "replicas": 3,
    "selector": {
      "matchLabels": {
        "apps.kubernetes.io/name": "minio-credential-injector"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "apps.kubernetes.io/name": "minio-credential-injector"
        },
        "annotations": {
          "sidecar.istio.io/inject": "false"
        }
      },
      "spec": {
        "serviceAccountName": "minio-credential-injector",
        "imagePullSecrets": [
          {
            "name": "k8scc01covidacr-registry-connection"
          }
        ],
        "containers": [
          {
            "name": "minio-credential-injector",
            "image": image,
            "env": [
              {
                "name": "VAULT_ADDR_HTTPS",
                "value": vault_addr_ext
              }
            ],
            "resources": {
              "limits": {
                "memory": "128Mi",
                "cpu": "500m"
              }
            },
            "ports": [
              {
                "name": "https",
                "containerPort": 8443
              }
            ],
            "volumeMounts": [
              {
                "name": "certs",
                "mountPath": "/certs",
                "readOnly": true
              },
              {
                "name": "instances",
                "mountPath": "/instances.json",
                "subPath": "instances.json",
                "readOnly": true
              }
            ]
          }
        ],
        "volumes": [
          {
            "name": "certs",
            "secret": {
              "secretName": "minio-credential-injector-tls"
            }
          },
          {
            "name": "instances",
            "configMap": {
              "name": "minio-instances-json"
            }
          }
        ]
      }
    }
  }
}
