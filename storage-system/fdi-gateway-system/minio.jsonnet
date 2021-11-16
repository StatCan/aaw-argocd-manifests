local appName = "minio";

local app = import '../../app.libsonnet';
local vars = app.extvars;

local values = |||
    ## MinIO(R) Gateway configuration
    nameOverride: "minio-gateway"
    commonLabels:
      app: minio-gateway
      data.statcan.gc.ca/classification: unclassified
    global:
      minio:
        existingSecret: minio-gateway-secret
    gateway:
      enabled: true
      type: azure
      auth:
        azure:
          storageAccountName: ${AZURE_STORAGE_ACCOUNT} 
          storageAccountKey: ${AZURE_STORAGE_KEY}
      updateStrategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: "25%%"
          maxUnavailable: "25%%"
      # autoscaling:
      #   enabled: true
      #   minReplicas: "2"
      #   maxReplicas: "4"
      #   targetCPU: "60"
      #   targetMemory: "60"
    extraEnv:
      - name: MINIO_ETCD_ENDPOINTS
        value: http://minio-gateway-etcd:2379/
      - name: MINIO_IAM_OPA_URL
        value: http://minio-gateway-opa:8181/v1/data/httpapi/authz
    extraVolumes:
    - name: minio-sh
      emptyDir: {}
    extraVolumeMounts:
    - mountPath: /minio.sh
      subPath: minio.sh
      name: minio-sh
    initContainers:
    - name: wait-for-sidecar
      image: busybox
      command:
      - sh
      - -c
      - |
        echo '#!/bin/sh' > /custom/minio.sh
        echo 'sleep 90'
        echo 'source /custom/creds.env'
        echo 'echo "Waiting for sidecar..."' >> /custom/minio.sh
        echo 'while ! curl -s -f http://127.0.0.1:15020/healthz/ready; do sleep 1; done' >> /custom/minio.sh
        echo 'echo "Sidecar is ready."' >> /custom/minio.sh
        echo 'echo exec minio $@' >> /custom/minio.sh
        echo 'exec minio $@' >> /custom/minio.sh
        chmod 555 /custom/minio.sh
        chown nobody:nobody /custom/minio.sh
        echo "Wrote the minio.sh script to shared volume."
      volumeMounts:
      - mountPath: /custom
        name: minio-sh
    sidecars: 
    - name: get-az-sa-creds
      image: mcr.microsoft.com/azure-cli:latest
      env: 
      - name: STORAGE_ACCOUNT_NAME
        valueFrom:
          secretKeyRef:
            name: azure-blob-storage
            key: storageAccountName 
      command: ["bin/bash", "-c"]
      args: [
        "az login --identity;
        AZURE_STORAGE_KEY=$(az storage account keys list -n $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)
        AZURE_STORAGE_ACCOUNT=$STORAGE_ACCOUNT_NAME
        echo "AZURE_STORAGE_KEY=$AZURE_STORAGE_KEY" > /custom/creds.env
        echo "AZURE_STORAGE_ACCOUNT=$AZURE_STORAGE_ACCOUNT" >> /custom/creds.env
        while true; do echo 'test'; sleep 600; done
        "
      ]
      volumeMounts:
      - mountPath: /custom
        name: minio-sh
    image:
      registry: k8scc01covidacr.azurecr.io
      repository: minio
      tag: 2021.5.27-debian-10-r8
      # registry: docker.io
      # repository: bitnami/minio
      # tag: 2021.5.27-debian-10-r8
    # Wait for the istio proxy
    command: ["sh", "/minio.sh"]
    podLabels:
      aadpodidbinding: fdi-sa-identity
    ingress:
      enabled: false
      hostname: %(namespace)s.%(domain)s
    resources:
      limits:
        cpu: "1"
        memory: 4Gi
      requests:
        cpu: "1"
        memory: 4Gi
    # nodeSelector:
    #   agentpool: storage
    # affinity:
    #   podAntiAffinity:
    #     preferredDuringSchedulingIgnoredDuringExecution:
    #     - podAffinityTerm:
    #         labelSelector:
    #           matchExpressions:
    #           - key: app
    #             operator: In
    #             values:
    #             - minio-gateway
    #         topologyKey: kubernetes.io/hostname
    #       weight: 100
    # tolerations:
    # - effect: NoSchedule
    #   key: node.statcan.gc.ca/purpose
    #   operator: Equal
    #   value: system
    # - effect: NoSchedule
    #   key: node.statcan.gc.ca/use
    #   operator: Equal
    #   value: storage
    # # - effect: NoSchedule
    # #   key: data.statcan.gc.ca/classification
    # #   operator: Equal
    # #   value: protected-b
    extraDeploy:
    - apiVersion: networking.istio.io/v1alpha3
      kind: DestinationRule
      metadata:
        name: minio-gateway
      spec:
        host: minio-gateway.%(namespace)s.svc.cluster.local
        trafficPolicy:
          tls:
            mode: ISTIO_MUTUAL
||| % {domain: vars.domain, namespace: vars.namespace};


{
  apiVersion: "argoproj.io/v1alpha1",
  kind: "Application",
  metadata: {
      name: vars.namespace + "-" + appName,
      namespace: vars.argocd_namespace
  },
  spec: {
    project: "default",
    destination: {
      namespace: vars.namespace,
      server: "https://kubernetes.default.svc"
    },
    source: {
      repoURL: "https://charts.bitnami.com/bitnami",
      chart: "minio",
      targetRevision: "7.2.0",
      helm: {
        releaseName: "minio-gateway",
        values: values,
      }
    },
    syncPolicy: {
      automated: {
        prune: true,
        selfHeal: true
      }
    }
  }
}
