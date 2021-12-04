# OPA Bundle Server

This MinIO instance, unlike the others, uses a remote OPA configuration. It was created for the purpose of collaborating with the FAIR Data Infrastructure team (FAIR-DI), so that they could manage the access to datasets themselves and have MinIO pick up their configuration automatically.

This setup requires an *additional* Storage Account to be created, in addition to the actual storage account used for the data. The second storage account stores [bundles](https://www.openpolicyagent.org/docs/latest/management-bundles/) of rego and json.
