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
    tag: 98baa4f33e5ab4b3302fdc20a88770f4413735ba

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
    blobcsi:
      config: |
          {"name": "standard", "classification": "unclassified", "secretRef": "aawdevcc00samgstandard/azure-blob-csi-system", "capacity": "10Ti", "readOnly": false, "owner": "AAW"}
          {"name": "premium", "classification": "unclassified", "secretRef": "aawdevcc00samgpremium/azure-blob-csi-system", "capacity": "10Ti", "readOnly": false, "owner": "AAW"}
          {"name": "standard-ro", "classification": "protected-b", "secretRef": "aawdevcc00samgstandard/azure-blob-csi-system", "capacity": "10Ti", "readOnly": true, "owner": "AAW"}
          {"name": "premium-ro", "classification": "protected-b", "secretRef": "aawdevcc00samgpremium/azure-blob-csi-system", "capacity": "10Ti", "readOnly": true, "owner": "AAW"}
          {"name": "protected-b", "classification": "protected-b", "secretRef": "aawdevcc00samgprotb/azure-blob-csi-system", "capacity": "10Ti", "readOnly": false, "owner": "AAW"}
      envFrom:
        - secretRef:
            name: "azure-blob-csi-fdi-unclassified"
        - secretRef:
            name: "azure-blob-csi-fdi-protected-b"
      env:
      - name: BLOB_CSI_FDI_OPA_DAEMON_TICKER_MILLIS
        value: 2000
      - name: BLOB_CSI_FDI_UNCLASS_OPA_ENDPOINT
        value: "http://minio-gateway-opa.fdi-gateway-unclassified-system.svc.cluster.local:8181/v1/data"
      - name: BLOB_CSI_FDI_UNCLASS_SPN_SECRET_NAME
        value: "azure-blob-csi-fdi-unclassified-spn"
      - name: BLOB_CSI_FDI_UNCLASS_SPN_SECRET_NAMESPACE
        value: "azure-blob-csi-system"
      - name: BLOB_CSI_FDI_UNCLASS_PV_STORAGE_CAP
        value: "100Gi"
      - name: BLOB_CSI_FDI_UNCLASS_AZURE_STORAGE_AUTH_TYPE
        value: "spn"
      - name: BLOB_CSI_FDI_UNCLASS_AZURE_STORAGE_AAD_ENDPOINT
        value: "https://login.microsoftonline.com"
      - name: BLOB_CSI_FDI_PROTECTED_B_OPA_ENDPOINT
        value: "http://minio-gateway-opa.fdi-gateway-protected-b-system.svc.cluster.local:8181/v1/data"
      - name: BLOB_CSI_FDI_PROTECTED_B_SPN_SECRET_NAME
        value: "azure-blob-csi-fdi-protected-b-spn"
      - name: BLOB_CSI_FDI_PROTECTED_B_SPN_SECRET_NAMESPACE
        value: "azure-blob-csi-system"
      - name: BLOB_CSI_FDI_PROTECTED_B_PV_STORAGE_CAP
        value: "100Gi"
      - name: BLOB_CSI_FDI_PROTECTED_B_AZURE_STORAGE_AUTH_TYPE
        value: "spn"
      - name: BLOB_CSI_FDI_PROTECTED_B_AZURE_STORAGE_AAD_ENDPOINT
        value: "https://login.microsoftonline.com"
    giteaUnclassified:
      envFrom:
        - secretRef:
            name: "gitea-postgres-connection-unclassified"
      env:
      - name: GITEA_CLASSIFICATION
        value: "unclassified"
      - name: GITEA_SERVICE_URL
        value: "gitea-unclassified-http"
      - name: GITEA_URL_PREFIX
        value: "gitea-unclassified"
      - name: GITEA_SERVICE_PORT
        value: 80
      - name: GITEA_BANNER_CONFIGMAP_NAME
        value: "gitea-banner-unclassified"
      - name: GITEA_ARGOCD_NAMESPACE
        value: "profiles-argocd-system"
      - name: GITEA_ARGOCD_SOURCE_REPO_URL
        value: https://github.com/StatCan/aaw-argocd-manifests.git
      - name: GITEA_ARGOCD_SOURCE_TARGET_REVISION
        value: "aaw-dev-cc-00"
      - name: GITEA_ARGOCD_SOURCE_PATH
        value: "profiles-argocd-system/template/gitea/unclassified"
      - name: GITEA_ARGOCD_PROJECT
        value: "default"
      - name: GITEA_SOURCE_CONTROL_ENABLED_LABEL
        value: "sourcecontrol.statcan.gc.ca/enabled"

    giteaProtectedB:
      envFrom:
        - secretRef:
            name: "gitea-postgres-connection-protected-b"
      env:
      - name: GITEA_CLASSIFICATION
        value: "protected-b"
      - name: GITEA_SERVICE_URL
        value: "gitea-protected-b-http"
      - name: GITEA_URL_PREFIX
        value: "gitea-protected-b"
      - name: GITEA_SERVICE_PORT
        value: 80
      - name: GITEA_BANNER_CONFIGMAP_NAME
        value: "gitea-banner-protected-b"
      - name: GITEA_ARGOCD_NAMESPACE
        value: "profiles-argocd-system"
      - name: GITEA_ARGOCD_SOURCE_REPO_URL
        value: https://github.com/StatCan/aaw-argocd-manifests.git
      - name: GITEA_ARGOCD_SOURCE_TARGET_REVISION
        value: "aaw-dev-cc-00"
      - name: GITEA_ARGOCD_SOURCE_PATH
        value: "profiles-argocd-system/template/gitea/protected-b"
      - name: GITEA_ARGOCD_PROJECT
        value: "default"
      - name: GITEA_SOURCE_CONTROL_ENABLED_LABEL
        value: "sourcecontrol.statcan.gc.ca/enabled"
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
      "targetRevision": "0.4.3",
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
