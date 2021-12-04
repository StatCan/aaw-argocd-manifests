# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "master"], std.extVar('targetRevision'));

local instances = if std.extVar('targetRevision') == "aaw-prod-cc-00" then 
{
    "instances.json": |||
    {"name": "minio_standard_tenant_1", "short": "standard", "classification": "unclassified", "externalUrl": "https://minio-standard-tenant-1.covid.cloud.statcan.ca:443"}
    {"name": "minio_premium_tenant_1", "short": "premium", "classification": "unclassified", "externalUrl": "https://minio-premium-tenant-1.covid.cloud.statcan.ca:443"}
|||
}
else
{
    "instances.json": |||
    {"name": "minio_standard", "short": "standard", "classification": "unclassified", "externalUrl": "https://minio-standard.aaw-dev.cloud.statcan.ca:443"}
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
