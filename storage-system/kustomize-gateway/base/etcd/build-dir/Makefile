../manifest.yaml: values.yaml
	helm repo add bitnami https://charts.bitnami.com/charts/ || true
	helm template minio-gateway-etcd bitnami/etcd \
		-f values.yaml \
		--version 6.13.2 > $@
