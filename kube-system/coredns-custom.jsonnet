# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));

# DOMAIN
local domain = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      "aaw.cloud.statcan.ca"
  else
      "aaw-dev.cloud.statcan.ca"
  ;

# INGRESS BASE (all envrionemnts)
local ingress_base = 
    "rewrite name vault." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name minio-gateway-standard-system-boathouse." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name minio-gateway-premium-system-boathouse." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name minio-gateway-standard-ro-system-boathouse." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name minio-gateway-premium-ro-system-boathouse." + domain + " istio-ingressgateway.istio-system.svc.cluster.local"
  ;

# INGRESS EXTRA (specific envrionemnts)
local ingress_extra = if std.extVar('targetRevision') == "aaw-prod-cc-00" then

    #PROD
    "rewrite name minio-standard-tenant-1.covid.cloud.statcan.ca istio-ingressgateway.istio-system.svc.cluster.local
rewrite name minio-premium-tenant-1.covid.cloud.statcan.ca istio-ingressgateway.istio-system.svc.cluster.local
rewrite name analytics-platform.statcan.gc.ca istio-ingressgateway.istio-system.svc.cluster.local
rewrite name plateforme-analyse.statcan.gc.ca istio-ingressgateway.istio-system.svc.cluster.local
rewrite name daaas-system-kibana." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name jfrog." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name vma-agdcc.statcan.gc.ca istio-ingressgateway-protected-b.istio-system.svc.cluster.local"

  else
  
    #DEV
    "rewrite name minio-standard." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name minio-premium." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name vetting." + domain + " istio-ingressgateway-protected-b.istio-system.svc.cluster.local
rewrite name console-minio-gateway-standard-system-boathouse." + domain + " istio-ingressgateway.istio-system.svc.cluster.local
rewrite name max-object-detector.christian-ritter." + domain + " istio-ingressgateway.istio-system.svc.cluster.local"
  ;

# KFSERVING BASE (all envrionemnts)
local kfserving_base = 
    "rewrite name max-object-detector.will-hearn." + domain + " istio-ingressgateway.istio-system.svc.cluster.local"
  ;

# KFSERVING EXTRA (specific envrionemnts)
local kfserving_extra = if std.extVar('targetRevision') == "aaw-prod-cc-00" then

    #PROD
    "rewrite name max-object-detector.zachary-seguin." + domain + " istio-ingressgateway.istio-system.svc.cluster.local"
    
  else
  
    #DEV
    ""
  ;

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'coredns-custom',
    namespace: 'kube-system',
    labels: {
      'addonmanager.kubernetes.io/mode': 'EnsureExists',
      'k8s-app': 'kube-dns',
      'kubernetes.io/cluster-service': 'true',
    },
  },
  data: {
    'ingress.override': ingress_base + "\n     " + ingress_extra,
    'kfserving-ingress.override': kfserving_base + "\n     " + kfserving_extra
  },
}
