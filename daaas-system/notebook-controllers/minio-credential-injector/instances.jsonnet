# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00"], std.extVar('targetRevision'));

local instances = if std.extVar('targetRevision') == "aaw-prod-cc-00" then
{
    "instances.json": |||
    {"name": "minio_gateway_standard", "alias": "minio-standard-tenant-1", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-standard-system:9000", "externalUrl": "https://minio-gateway-standard-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "minio_gateway_premium", "alias": "minio-premium-tenant-1", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-premium-system:9000", "externalUrl": "https://minio-gateway-premium-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "minio_gateway_standard", "alias": "", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-standard-system:9000", "externalUrl": "https://minio-gateway-standard-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "minio_gateway_premium", "alias": "", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-premium-system:9000", "externalUrl": "https://minio-gateway-premium-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "minio_gateway_standard_ro", "alias": "", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-standard-ro-system:9000", "externalUrl": "https://minio-gateway-standard-ro-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "minio_gateway_premium_ro", "alias": "", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-premium-ro-system:9000", "externalUrl": "https://minio-gateway-premium-ro-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "minio_gateway_protected_b", "alias": "", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-protected-b-system:9000", "externalUrl": ""}
    {"name": "fdi_gateway_unclassified", "alias": "", "classification": "unclassified", "serviceUrl": "http://minio-gateway.fdi-gateway-unclassified-system:9000", "externalUrl": "https://fdi-gateway-unclassified-system-boathouse.aaw.cloud.statcan.ca"}
    {"name": "fdi_gateway_protected_b", "alias": "", "classification": "protected-b", "serviceUrl": "http://minio-gateway.fdi-gateway-protected-b-system:9000", "externalUrl": ""}
|||
}
else
{
    "instances.json": |||
    {"name": "minio_gateway_protected_b", "alias": "", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-protected-b-system:9000", "externalUrl": ""}
    {"name": "minio_gateway_standard", "alias": "minio-standard-tenant-1", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-standard-system:9000", "externalUrl": "https://minio-gateway-standard-system-boathouse.aaw-dev.cloud.statcan.ca"}
    {"name": "minio_gateway_standard", "alias": "", "classification": "unclassified", "serviceUrl": "http://minio-gateway.minio-gateway-standard-system:9000", "externalUrl": "https://minio-gateway-standard-system-boathouse.aaw-dev.cloud.statcan.ca"}
    {"name": "minio_gateway_standard_ro", "alias": "", "classification": "protected-b", "serviceUrl": "http://minio-gateway.minio-gateway-standard-ro-system:9000", "externalUrl": "https://minio-gateway-standard-ro-system-boathouse.aaw-dev.cloud.statcan.ca"}
    {"name": "fdi_gateway_unclassified", "alias": "", "classification": "unclassified", "serviceUrl": "http://minio-gateway.fdi-gateway-unclassified-system:9000", "externalUrl": ""}
    {"name": "fdi_gateway_protected_b", "alias": "", "classification": "protected-b", "serviceUrl": "http://minio-gateway.fdi-gateway-protected-b-system:9000", "externalUrl": ""}
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
