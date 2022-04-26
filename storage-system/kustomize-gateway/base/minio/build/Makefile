../manifest.yaml: kustomization.yaml values.yaml
	kustomize build . \
			--load-restrictor LoadRestrictionsNone \
			--enable-helm \
		> $@
