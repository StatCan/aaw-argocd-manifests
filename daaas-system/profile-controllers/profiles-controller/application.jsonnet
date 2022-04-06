local vars = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      {
         vault_path: "auth/aaw-prod-cc-00",
         oidc_accessor: "auth_oidc_8a2fe3d8",
         buckets: "minio_gateway_standard,minio_gateway_premium,minio_gateway_protected_b",
         mounts: "minio_gateway_standard,minio_gateway_standard_ro,minio_gateway_premium,minio_gateway_premium_ro,minio_gateway_protected_b,fdi_gateway_unclassified,fdi_gateway_protected_b"
      }
    else
      {
         vault_path: "auth/aaw-dev-cc-00",
         oidc_accessor: "auth_oidc_6fdc919f",
         buckets: "minio_gateway_standard,minio_gateway_premium",
         mounts: "minio_gateway_standard,minio_gateway_standard_ro,minio_gateway_premium,minio_gateway_premium_ro,fdi_gateway_unclassified"
      }
    ;

local values = |||
  image:
    repository: k8scc01covidacr.azurecr.io/profiles-controller
    tag: 6d549a7e781e204715b7ac544dd4ad6f50712533

  extraEnv:
  - name: REQUEUE_TIME
    value: "5"

  vaultagent:
    enabled: true
    config: |
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

  components:
    rbac:
      supportGroups:
        # DAaaS-AAW-Support
        - 468415c1-d3c2-4c7c-a69d-38f3ce11d351
    gitea:
      namespace: "profiles-argocd-system"
    buckets:
      instances: %(instances)s
||| % {mount_path: vars.vault_path, instances: vars.buckets};



{
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Application",
  "metadata": {
    "name": "profiles-controller",
    "namespace": "daaas-system"
  },
  "spec": {
    "project": "platform",
    "destination": {
      "namespace": "daaas-system",
      "name": "in-cluster"
    },
    "source": {
      "repoURL": "https://statcan.github.io/charts",
      "chart": "profiles-controller",
      "targetRevision": "0.2.0",
      "helm": {
        "releaseName": "profiles-controller",
        "values": values
      }
    },
    "syncPolicy": {
      "automated": {
        "prune": true,
        "selfHeal": true
      }
    }
  }
}
