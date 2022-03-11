local image = "k8scc01covidacr.azurecr.io/kubeflow-controller:a2c0175561081209ca44921658139ab284265cd8";

assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));


local vars = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      {
         vault_path: "auth/" + std.extVar('targetRevision'),
         oidc_accessor: "auth_oidc_8a2fe3d8",
         minio_instances: "fdi_gateway_unclassified,fdi_gateway_protected_b,minio_gateway_standard_ro,minio_gateway_premium_ro,minio_gateway_standard,minio_gateway_premium,minio_gateway_protected_b"
      }
    else
      {
         vault_path: "auth/aaw-dev-cc-00",
         oidc_accessor: "auth_oidc_6fdc919f",
         minio_instances: "minio_gateway_standard,minio_gateway_standard_ro,minio_gateway_premium,minio_gateway_premium_ro,fdi_gateway_unclassified,minio_gateway_protected_b,fdi_gateway_protected_b"
      }
    ;

local config = |||
    "auto_auth" = {
      "method" = {
        "config" = {
          "role" = "profile-configurator"
        }
        "type" = "kubernetes"
        "mount_path" = "%(mount_path)s"
      }
    }

    "exit_after_auth" = false
    "pid_file" = "/home/vault/.pid"

    cache {
      "use_auto_auth_token" = "force"
    }

    listener "tcp" {
      address = "127.0.0.1:8100"
      "tls_disable" = true
    }

    "vault" = {
      "address" = "http://vault.vault-system:8200"
    }
||| % {mount_path: vars.vault_path};



[
    {
      apiVersion: "v1",
      kind: "ConfigMap",
      metadata: {
        name: "profile-configurator-vault-agent-config",
        namespace: "daaas-system"
      },
      data: {
        "config.hcl": config
      }
    },
    {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
        "name": "profile-configurator",
        "namespace": "daaas-system",
        "labels": {
          "apps.kubernetes.io/name": "profile-configurator"
        }
      },
      "spec": {
        "selector": {
          "matchLabels": {
            "apps.kubernetes.io/name": "profile-configurator"
          }
        },
        "template": {
          "metadata": {
            "labels": {
              "apps.kubernetes.io/name": "profile-configurator"
            },
            "annotations": {
              "vault.hashicorp.com/agent-inject": "true",
              "vault.hashicorp.com/agent-configmap": "profile-configurator-vault-agent-config",
              "vault.hashicorp.com/agent-pre-populate": "false"
            }
          },
          "spec": {
            "serviceAccountName": "profile-configurator",
            "imagePullSecrets": [
              {
                "name": "k8scc01covidacr-registry-connection"
              }
            ],
            "containers": [
              {
                "name": "profile-configurator",
                "image": image,
                "resources": {
                  "limits": {
                    "memory": "128Mi",
                    "cpu": "500m"
                  }
                },
                "env": [
                  {
                    "name": "VAULT_AGENT_ADDR",
                    "value": "http://127.0.0.1:8100"
                  },
                  {
                    "name": "MINIO_INSTANCES",
                    "value": vars.minio_instances
                  },
                  {
                    "name": "KUBERNETES_AUTH_PATH",
                    "value": vars.vault_path
                  },
                  {
                    "name": "OIDC_AUTH_ACCESSOR",
                    "value": vars.oidc_accessor
                  }
                ]
              }
            ]
          }
        }
      }
    }
]
