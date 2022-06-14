ifeq (, $(shell whereis yq))
YQ := cat
else
YQ := yq -P e -
endif

# define classifications here
CLASSIFICATIONS := unclassified protected-b
KUSTOMIZE_BUILD := kustomize build
HELM_VERSION        := v5.0.4
# Declare which targets are not files to avoid conflicts
.PHONY: clean kustomize helm-build install

helm-build:
	helm repo add gitea-charts https://dl.gitea.io/charts/ || true
	helm repo update || true
	for classification in $(CLASSIFICATIONS); do \
		helm template gitea-$${classification} gitea-charts/gitea --version $(HELM_VERSION) -f $${classification}/values.yaml | tee $${classification}/manifest.yaml | $(YQ); \
	done

install:
	@echo installing to active kube context.
	kubectl create ns gitea-default || true
	for classification in $(CLASSIFICATIONS); do \
		kubectl create cm gitea-banner-$${classification} --from-literal=body_inner_pre.tmpl="Welcome to AAW Gitea ($${classification}). \
		To login use username: superuser, password: password | Bienvenue à AAW Gitea. Pour vous connecter, \
		utilisez le nom d'utilisateur: superuser, le mot de passe: password" -n gitea-default; \
		$(KUSTOMIZE_BUILD) ./$${classification} | kubectl apply -n gitea-default -f -; \
	done

clean:
	@echo deleting ns gitea-default!
	kubectl delete ns gitea-default

kustomize:
	for classification in $(CLASSIFICATIONS); do \
		@echo applying kustomize to ./$${classification}/manifest.yaml manifest; \
		$(KUSTOMIZE_BUILD) ./$${classification} | $(YQ); \
	done
