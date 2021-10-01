local namespace = std.extVar("namespace");
local image = "openpolicyagent/opa:0.32.0";

[
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "minio-opa"
    },
    data: {
      "policy.rego": importstr 'policy.rego'
    }
  },
  {
    apiVersion: "networking.istio.io/v1alpha3",
    kind: "DestinationRule",
    metadata: {
      name: "minio-gateway-opa"
    },
    spec: {
      host: "minio-opa.%s.svc.cluster.local" % namespace,
      trafficPolicy: {
        tls: {
          mode: "ISTIO_MUTUAL"
        }
      }
    }
  },
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: "minio-opa",
      namespace: namespace,
      labels: {
        "app.kubernetes.io/name": "minio-opa"
      }
    },
    spec: {
      type: "ClusterIP",
      ports: [
        {
          port: 8181,
          targetPort: 8181,
          protocol: "TCP",
          name: "http"
        }
      ],
      selector: {
        "app.kubernetes.io/name": "minio-opa"
      }
    }
  },
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: "minio-opa",
      namespace: namespace,
      labels: {
        "app.kubernetes.io/name": "minio-opa"
      }
    },
    spec: {
      replicas: 3,
      selector: {
        matchLabels: {
          "app.kubernetes.io/name": "minio-opa"
        }
      },
      template: {
        metadata: {
          labels: {
            "app.kubernetes.io/name": "minio-opa"
          }
        },
        spec: {
          securityContext: {},
          containers: [
            {
              name: "opa",
              securityContext: {},
              image: image,
              imagePullPolicy: "Always",
              args: [
                "run",
                "--ignore=.*",
                "--server",
                "/policies"
              ],
              env: [
                {
                  name: "MINIO_ADMIN",
                  valueFrom: {
                    secretKeyRef: {
                      name: "minio-gateway-secret",
                      key: "access-key"
                    }
                  }
                }
              ],
              ports: [
                {
                  name: "http",
                  containerPort: 8181,
                  protocol: "TCP"
                }
              ],
              livenessProbe: {
                httpGet: {
                  path: "/",
                  port: 8181,
                  scheme: "HTTP"
                },
                initialDelaySeconds: 5,
                timeoutSeconds: 1,
                periodSeconds: 5,
                successThreshold: 1,
                failureThreshold: 3
              },
              readinessProbe: {
                httpGet: {
                  path: "/health?bundle=true",
                  port: 8181,
                  scheme: "HTTP"
                },
                initialDelaySeconds: 5,
                timeoutSeconds: 1,
                periodSeconds: 5,
                successThreshold: 1,
                failureThreshold: 3
              },
              resources: {
                limits: {
                  cpu: "1",
                  memory: "1Gi"
                },
                requests: {
                  cpu: "100m",
                  memory: "200Mi"
                }
              },
              volumeMounts: [
                {
                  name: "policies",
                  readOnly: true,
                  mountPath: "/policies",
                  mountPropagation: "None"
                }
              ]
            }
          ],
          volumes: [
            {
              name: "policies",
              configMap: {
                name: "minio-opa",
                defaultMode: 420
              }
            }
          ]
        }
      },
      strategy: {
        type: "RollingUpdate",
        rollingUpdate: {
          maxUnavailable: "25%",
          maxSurge: "25%"
        }
      }
    }
  }
]