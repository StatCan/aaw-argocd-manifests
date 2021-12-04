# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00"], std.extVar('targetRevision'));

local instances = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
{
    "instances.json": |||
    {"name": "minio_standard_tenant_1", "classification": "unclassified", "serviceUrl": "http://minio.minio-legacy-system:80"}
    {"name": "minio_premium_tenant_1", "classification": "unclassified", "serviceUrl": "http://minio.minio-premium-legacy-system:80"}
|||
}
else
{
    "instances.json": |||
    {"name": "minio_standard", "classification": "unclassified", "serviceUrl": "http://minio.minio-standard-system:443"}
    {"name": "minio_protected_b", "classification": "protected-b", "serviceUrl": "http://minio.minio-protected-b-system:443"}
    {"name": "fdi_gateway", "classification": "unclassified", "serviceUrl": "http://minio-gateway.fdi-gateway-system:9000"}
    {"name": "minio_gateway_standard", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-standard-system:9000"}
    {"name": "minio_gateway_premium", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-premium-system:9000"}
    {"name": "minio_gateway_standard_ro", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-standard-ro-system:9000"}
    {"name": "minio_gateway_premium_ro", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-premium-ro-system:9000"}
|||
};




{
  "apiVersion": "v1",
  "kind": "ConfigMap",
  "metadata": {
    "name": "minio-instances-json",
    "namespace": "daaas-system"
  },
  "data": instances
}
