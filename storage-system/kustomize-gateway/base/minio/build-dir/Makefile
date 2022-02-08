../manifest.yaml: values.yaml
	helm repo add bitnami https://charts.bitnami.com/charts/ || true
	helm template minio-gateway bitnami/minio \
		-f values.yaml \
		--version 10.0.3 > $@
