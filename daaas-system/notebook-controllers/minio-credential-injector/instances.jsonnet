# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00"], std.extVar('targetRevision'));

local instances = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
{
    "instances.json": |||
    {"name": "minio_standard_tenant_1", "classification": "unclassified", "serviceUrl": "http://minio.minio-legacy-system:80", "externalUrl": "https://minio-standard-tenant-1.covid.cloud.statcan.ca"}
    {"name": "minio_premium_tenant_1", "classification": "unclassified", "serviceUrl": "http://minio.minio-premium-legacy-system:80", "externalUrl": "https://minio-premium-tenant-1.covid.cloud.statcan.ca"}
    {"name": "minio_gateway_standard_ro", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-standard-ro-system:9000", "externalUrl": "https://minio-gateway-standard-ro-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "minio_gateway_premium_ro", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-premium-ro-system:9000", "externalUrl": "https://minio-gateway-premium-ro-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "fdi_gateway_unclassified", "classification": "unclassified", "serviceUrl": "http://minio-gateway.fdi-gateway-unclassified-system:9000", "externalUrl": "https://fdi-gateway-unclassified-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "fdi_gateway_protected_b", "classification": "protected-b", "serviceUrl": "http://minio-gateway.fdi-gateway-protected-b-system:9000", "externalUrl": ""}
|||
}
else
{
    "instances.json": |||
    {"name": "minio_standard", "classification": "unclassified", "serviceUrl": "http://minio.minio-standard-system:443", "externalUrl": "https://minio-standard.aaw-dev.cloud.statcan.ca"}
    {"name": "minio_protected_b", "classification": "protected-b", "serviceUrl": "http://minio.minio-protected-b-system:443", "externalUrl": ""}
    {"name": "minio_gateway_standard", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-standard-system:9000", "externalUrl": "https://minio-gateway-standard-system-boathouse.aaw-dev.cloud.statcan.ca"}
    {"name": "minio_gateway_standard_ro", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-standard-ro-system:9000", "externalUrl": "https://minio-gateway-standard-ro-system-boathouse.aaw-dev.cloud.statcan.ca"}
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
