# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00"], std.extVar('targetRevision'));

local domain = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      "aaw.cloud.statcan.ca"
  else
      "aaw-dev.cloud.statcan.ca"
  ;

[
{
  "apiVersion": "networking.k8s.io/v1",
  "kind": "Ingress",
  "metadata": {
    "name": "kibana-ingress",
    "namespace": "org-ces-system",
    "annotations": {
      "kubernetes.io/ingress.class": "istio"
    },
  },
  "spec": {
    "rules": [
      {
        "host": "org-ces-system-kibana." + domain,
        "http": {
          "paths": [
            {
              "backend": {
                "serviceName": "vetting-kb-http",
                "servicePort": 5601
              },
              "path": "/*",
              "pathType": "ImplementationSpecific"
            }
          ],
        }
      }
    ]
  }
}
]
