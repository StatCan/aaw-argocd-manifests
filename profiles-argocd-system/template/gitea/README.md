# Gitea Manifest
This is the default installation manifest for gitea.

Patches have been applied to the [gitea helm chart](https://gitea.com/gitea/helm-chart) via kustomize, in [kustomize.yaml](./kustomization.yaml).

## Install Locally
- To test in a local cluster, run the following commands.

```bash
make install
```

- [manifest.yaml](./manifest.yaml) is the manifest generated from purely the [gitea helm chart](https://gitea.com/gitea/helm-chart).

## View the customized manifest
Run the below command to generate the customized yaml.
```bash
make
```
