# Only have dev and prod at the moment
#assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));
local isProd = std.extVar('targetRevision') == "aaw-prod-cc-00";

# Domains
local aawDomain = if isProd then "aaw.cloud.statcan.ca" else "aaw-dev.cloud.statcan.ca";
local statcanDomain = "statcan.gc.ca";
local covidDomain = "covid.cloud.statcan.ca";

#Gateways
local defaultGateway = "istio-ingressgateway.istio-system.svc.cluster.local";                                                                                                                                                                                                                                                                                                           
local protectedGateway = "istio-ingressgateway-protected-b.istio-system.svc.cluster.local"; 
  
local rewrite(subdomain, gateway, domain=aawDomain) = "rewrite name %(subdomain)s.%(domain)s %(gateway)s\n" % {                                                                                                                                                                                                                                                                                             
  subdomain: subdomain,                                                                                                                                                                                                                                                                                                                                                                 
  gateway: gateway,                                                                                                                                                                                                                                                                                                                                                                     
  domain: domain                                                                                                                                                                                                                                                                                                                                                                        
}; 

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
    'ingress.override': 
      rewrite("vault", defaultGateway) +
      rewrite("minio-gateway-standard-system-boathouse", defaultGateway) +
      rewrite("minio-gateway-premium-system-boathouse", defaultGateway) +
      rewrite("minio-gateway-standard-ro-system-boathouse", defaultGateway) +
      rewrite("minio-gateway-premium-ro-system-boathouse", defaultGateway) +
      
      if isProd then
        #PROD ONLY
        rewrite("minio-standard-tenant-1", defaultGateway, covidDomain) +
        rewrite("minio-premium-tenant-1", defaultGateway, covidDomain) +
        rewrite("analytics-platform", defaultGateway, statcanDomain) +
        rewrite("plateforme-analyse", defaultGateway, statcanDomain) +
        rewrite("daaas-system-kibana", defaultGateway) +
        rewrite("jfrog", defaultGateway) +
        rewrite("vma-agdcc", protectedGateway, statcanDomain)
      else
        #DEV ONLY
        rewrite("minio-standard", defaultGateway) +
        rewrite("minio-premium", defaultGateway) +
        rewrite("console-minio-gateway-standard-system-boathouse", defaultGateway) +
        rewrite("max-object-detector.christian-ritter", defaultGateway) +
        rewrite("vetting", protectedGateway)
  },
}
