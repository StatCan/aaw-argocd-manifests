# Gitea Manifest
This is the default installation manifest for gitea unclassified, and protected-b.

# Deployment
The [gitea helm chart](https://gitea.com/gitea/helm-chart) is templated as unclassified and protected-b manifests providing:
[unclassified](./unclassified/manifest.yaml) and [protected-b](./protectedb/manifest.yaml) manifest files.
Prior to deployment, patches should be applied to the each
[unclassified](./unclassified/manifest.yaml) and [protected-b](./protectedb/manifest.yaml) manifest files via kustomiz.

Any kustomization common to the unclassified and protected-b gitea deployments is contained within the `base/` directory.
Additional kustomization patches specific to application can be defined in the `unclassified/` or
`protectedb/` directories.

# Install Locally
1. To regenerate [unclassified](./unclassified/manifest.yaml) and [protected-b](./protectedb/manifest.yaml) manifest files,
run
```bash
make helm-build
```

2. To install kustomized manifests in a local cluster, run the following:

```bash
make install
```

# Project Structure
```bash
gitea
├── Makefile
├── protected-b
│   ├── kustomization.yaml
│   ├── manifest.yaml
│   └── values.yaml
├── README.md
└── unclassified
    ├── kustomization.yaml
    ├── manifest.yaml
    └── values.yaml
```
- Notice that the `protected-b/` and `unclassified/` directories contain a `kustomization.yaml`, `manifest.yaml`, and `values.yaml` file,
where:
  - `kustomization.yaml` contains kustomization specific to the corresponding `manifest.yaml` file in the **same** directory
  - `manifest.yaml` is the pure gitea manifest generated from the gitea helm chart **see `helm build` in the [Makefile](./Makefile)**
  - `values.yaml` is the configuration file for the gitea helm chart

# View the Kustomized Manifests
Run the below command to generate the kustomized yaml, outputted to your terminal.
- unclassified
```bash
make kustomize-unclassified
```
- protected-b
```bash
make kustomized-protectedb
```

# Additional Notes
Any commits to the project with trigger a git hook to rebuild the [gitea helm chart](https://gitea.com/gitea/helm-chart) for
unclassified and protected-b.
