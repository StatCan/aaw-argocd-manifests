# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00"], std.extVar('targetRevision'));

local domain = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
      "aaw.cloud.statcan.ca"
  else
      "aaw-dev.cloud.statcan.ca"
  ;

[
  {
    "apiVersion": "networking.istio.io/v1beta1",
    "kind": "VirtualService",
    "metadata": {
      "name": "elastic-ingress",
      "namespace": "org-ces-system"
    },
    "spec": {
      "gateways": [
        "istio-system/istio-ingressgateway-protected-b"
      ],
      "hosts": [
        "org-ces-system-elastic." + domain
      ],
      "http": [
        {
          "match": [
            {
              "uri": {
                "prefix": "/"
              }
            }
          ],
          "route": [
            {
              "destination": {
                "host": "vetting-es-http.org-ces-system.svc.cluster.local",
                "port": {
                  "number": 9200
                }
              }
            }
          ]
        }
      ]
    }
  },
  {
    "apiVersion": "networking.istio.io/v1beta1",
    "kind": "VirtualService",
    "metadata": {
      "name": "kibana-ingress",
      "namespace": "org-ces-system"
    },
    "spec": {
      "gateways": [
        "istio-system/authenticated"
      ],
      "hosts": [
        "org-ces-system-kibana." + domain
      ],
      "http": [
        {
          "match": [
            {
              "uri": {
                "prefix": "/"
              }
            }
          ],
          "route": [
            {
              "destination": {
                "host": "vetting-kb-http.org-ces-system.svc.cluster.local",
                "port": {
                  "number": 5601
                }
              }
            }
          ]
        }
      ]
    }
  }
]
