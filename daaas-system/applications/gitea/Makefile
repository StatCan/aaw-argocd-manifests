install: manifest.yaml
	@echo installing to active kube context.
	kubectl create ns gitea-default
	kubectl create cm gitea-banner --from-literal=body_inner_pre.tmpl="Welcome to AAW Gitea. To login use username: superuser, password: password | Bienvenue à AAW Gitea. Pour vous connecter, utilisez le nom d'utilisateur: superuser, le mot de passe: password" -n gitea-default
	kustomize build . | kubectl apply -n gitea-default -f -

manifest.yaml: values.yaml
	@echo generating manifest.yaml file.
	helm repo add gitea-charts https://dl.gitea.io/charts/ || true
	helm repo update || true
	helm template gitea gitea-charts/gitea --version v5.0.4 -f values.yaml > $@

clean:
	@echo deleting ns gitea-default!
	kubectl delete ns gitea-default


