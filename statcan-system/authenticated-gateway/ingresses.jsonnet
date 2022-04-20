# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));

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
      "name": "kubecost",
      "namespace": "kubecost-system"
    },
    "spec": {
      "gateways": [
        "istio-system/authenticated-istio-ingress-gateway-https"
      ],
      "hosts": [
        "kubecost." + domain
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
                "host": "kubecost-cost-analyzer.kubecost-system.svc.cluster.local",
                "port": {
                  "number": 9090
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
      "name": "prometheus",
      "namespace": "prometheus-system"
    },
    "spec": {
      "gateways": [
        "istio-system/authenticated-istio-ingress-gateway-https"
      ],
      "hosts": [
        "prometheus." + domain
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
                "host": "prometheus-operator-prometheus.prometheus-system.svc.cluster.local",
                "port": {
                  "number": 9090
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
      "name": "alertmanager",
      "namespace": "prometheus-system"
    },
    "spec": {
      "gateways": [
        "istio-system/authenticated-istio-ingress-gateway-https"
      ],
      "hosts": [
        "alertmanager." + domain
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
                "host": "prometheus-operator-alertmanager.prometheus-system.svc.cluster.local",
                "port": {
                  "number": 9093
                }
              }
            }
          ]
        }
      ]
    }
  }
]
