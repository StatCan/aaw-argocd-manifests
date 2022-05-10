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
      "name": "kibana-monitoring",
      "namespace": "monitoring-system"
    },
    "spec": {
      "gateways": [
        "istio-system/authenticated-istio-ingress-gateway-https"
      ],
      "hosts": [
        "monitoring-kibana." + domain
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
                "host": "kibana-monitoring-kb-http.monitoring-system.svc.cluster.local",
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
