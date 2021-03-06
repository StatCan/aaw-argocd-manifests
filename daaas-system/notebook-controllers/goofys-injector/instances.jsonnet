# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));

local instances = if std.extVar('targetRevision') == "aaw-prod-cc-00" then 
{
    "instances.json": |||
    {"name": "minio_gateway_standard", "short": "standard", "classification": "unclassified", "externalUrl": "https://minio-gateway-standard-system-boathouse.aaw.cloud.statcan.ca:443"}
    {"name": "minio_gateway_standard_ro", "short": "standard-ro", "classification": "protected-b", "externalUrl": "https://minio-gateway-standard-ro-system-boathouse.aaw.cloud.statcan.ca:443"}
    {"name": "minio_gateway_premium", "short": "premium", "classification": "unclassified", "externalUrl": "https://minio-gateway-premium-system-boathouse.aaw.cloud.statcan.ca:443"}
    {"name": "minio_gateway_premium_ro", "short": "premium-ro", "classification": "protected-b", "externalUrl": "https://minio-gateway-premium-ro-system-boathouse.aaw.cloud.statcan.ca:443"}
|||
}
else
{
    "instances.json": |||
    {"name": "minio_gateway_standard", "short": "standard", "classification": "unclassified", "externalUrl": "https://minio-gateway-standard-system-boathouse.aaw-dev.cloud.statcan.ca:443"}
    {"name": "minio_gateway_standard_ro", "short": "standard-ro", "classification": "protected-b", "externalUrl": "https://minio-gateway-standard-ro-system-boathouse.aaw-dev.cloud.statcan.ca:443"}
|||
};


{
  "apiVersion": "v1",
  "kind": "ConfigMap",
  "metadata": {
    "name": "minio-instances-goofys",
    "namespace": "daaas-system"
  },
  "data": instances
}
