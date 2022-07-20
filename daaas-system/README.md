# Deployment Overview

The primary tool used for AAW deployments is [ArgoCD]().

## Components Deployed by the `daaas-system` ArgoCD Instance

The following links can be used to access the [daaas-system ArgoCD Prod Instance](https://daaas-system-argocd.aaw.cloud.statcan.ca/) and the [daaas-system ArgoCD Dev Instance](https://daaas-system-argocd.aaw-dev.cloud.statcan.ca/).

A [root `daaas-system` ArgoCD Application](https://gitlab.k8s.cloud.statcan.ca/cloudnative/aaw/daaas-infrastructure/aaw-dev-cc-00/-/blob/main/argocd_operator.tf#L384-415) is installed to the dev/prod cluster directly via terraform. The following links can be used to access the [root `daaas-system` ArgoCD Prod Application](https://gitlab.k8s.cloud.statcan.ca/cloudnative/aaw/daaas-infrastructure/aaw-prod-cc-00/-/blob/main/argocd_operator.tf#L280-311) and the [root `daaas-system` ArgoCD Dev Application](https://gitlab.k8s.cloud.statcan.ca/cloudnative/aaw/daaas-infrastructure/aaw-dev-cc-00/-/blob/main/argocd_operator.tf#L384-415). These instances respectively watch the `aaw-prod-cc-00` and `aaw-dev-cc-00` branches of the [aaw-argocd-manifests](https://github.com/StatCan/aaw-argocd-manifests) repositories. The content in this section details which application components are deployed by each part of the `aaw-argocd-manifests` repository.

>  TODO