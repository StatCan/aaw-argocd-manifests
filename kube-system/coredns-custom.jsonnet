# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));

local domain = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      "aaw.cloud.statcan.ca"
  else
      "aaw-dev.cloud.statcan.ca"
  ;

[
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
      'ingress.override': 'rewrite name vault.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name vetting.' + domain + ' istio-ingressgateway-protected-b.istio-system.svc.cluster.local\n
        rewrite name minio-gateway-standard-system-boathouse.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name console-minio-gateway-standard-system-boathouse.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name minio-gateway-premium-system-boathouse.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name minio-gateway-standard-ro-system-boathouse.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name minio-gateway-premium-ro-system-boathouse.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name minio-standard.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name minio-premium.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local\n
        rewrite name max-object-detector.christian-ritter.' + domain + ' istio-ingressgateway.istio-system.svc.cluster.local',
      'kfserving-ingress.override': 'rewrite name max-object-detector.will-hearn.' + domain + 'istio-ingressgateway.istio-system.svc.cluster.local',
    },
  },
]
