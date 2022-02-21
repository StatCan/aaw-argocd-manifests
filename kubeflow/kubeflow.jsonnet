# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00", "feat-kubeflow-manifests"], std.extVar('targetRevision'));


local appsetVersion = "0.1.0";

// Old Application sets require `url` and `cluster` to be set.
local applicationset_compatibility_fix(x) =
  if appsetVersion == "0.1.0"
  then {url: "https://kubernetes.default.svc", cluster: "in-cluster", values: x}
  else x;


{
  apiVersion: "argoproj.io/v1alpha1",
  kind: "ApplicationSet",
  metadata: {
    name: "kubeflow",
    namespace: "daaas-system"
  },
  spec: {
    generators: [
      {
        list: {
          elements: std.map(applicationset_compatibility_fix, [
            {
              app: "common/kubeflow-namespace",
              overlay: "base"
            },
            # Example, if you need a dev/prod split, use
            # > overlay: "overlays/" + std.extVar('targetRevision')
            # and have a dev and prod overlay in aaw-kubeflow-manifests.
            {
              app: "common/kubeflow-roles",
              overlay: "base"
            },
            {
              app: "common/oidc-authservice",
              overlay: "base"
            },
            {
              app: "common/knative",
              overlay: "base"
            },
            {
              app: "apps/admission-webhook",
              overlay: "base"
            },
            {
              app: "apps/centraldashboard",
              overlay: "base"
            },
            {
              app: "apps/jupyter-web-app",
              overlay: "base"
            },
            {
              app: "apps/katib",
              overlay: "base"
            },
            {
              app: "apps/kfserving",
              overlay: "base"
            },
            {
              app: "apps/mpi-job",
              overlay: "base"
            },
            {
              app: "apps/mxnet-job",
              overlay: "base"
            },
            {
              app: "apps/notebook-controller",
              overlay: "base"
            },
            {
              app: "apps/pipeline",
              overlay: "base"
            },
            {
              app: "apps/profiles",
              overlay: "base"
            },
            {
              app: "apps/pytorch-job",
              overlay: "base"
            },
            {
              app: "apps/tr-training",
              overlay: "base"
            },
            {
              app: "apps/seldon",
              overlay: "base"
            },
            {
              app: "apps/spark",
              overlay: "base"
            }
          ])
        }
      }
    ],
    template: {
      metadata: {
        name: "kubeflow-aaw",
        namespace: "daaas-system"
      },
      spec: {
        destination: {
          name: "in-cluster",
          namespace: "daaas-system"
        },
        project: "default",
        source: {
          path: if appsetVersion == "0.1.0"
                then "kustomize/{{values.app}}/{{values.overlay}}"
                else "kustomize/{{app}}/{{overlay}}",
          repoURL: "https://github.com/statcan/aaw-kubeflow-manifests.git",
          targetRevision: std.extVar('targetRevision')
        },
        #syncPolicy: {
        #  automated: {
        #    prune: true,
        #    selfHeal: true
        #  }
        #}
      }
    }
  }
}
