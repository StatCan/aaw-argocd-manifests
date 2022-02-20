# Only have dev and prod at the moment
assert std.member(["aaw-dev-cc-00", "aaw-prod-cc-00"], std.extVar('targetRevision'));

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
          elements: [
            {
              app: "kubeflow-namespace",
              folder: "common",
              overlay: "base"
              # Example, if you need a dev/prod split, use
              # > overlay: "overlays/" + std.extVar('targetRevision')
              # and have a dev and prod overlay in aaw-kubeflow-manifests.
            },
            {
              app: "kubeflow-roles",
              folder: "common",
              overlay: "base"
            },
            {
              app: "oidc-authservice",
              folder: "common",
              overlay: "base"
            },
            {
              app: "knative",
              folder: "common",
              overlay: "base"
            },
            {
              app: "admission-webhook",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "centraldashboard",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "jupyter-web-app",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "katib",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "kfserving",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "mpi-job",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "mxnet-job",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "notebook-controller",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "pipeline",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "profiles",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "pytorch-job",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "tr-training",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "seldon",
              folder: "apps",
              overlay: "base"
            },
            {
              app: "spark",
              folder: "apps",
              overlay: "base"
            }
          ]
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
          path: "kustomize/{{folder}}/{{app}}/{{overlay}}",
          repoURL: "https://github.com/statcan/aaw-kubeflow-manifests.git",
          targetRevision: std.extVar('targetRevision')
        },
        syncPolicy: {
          automated: {
            prune: true,
            selfHeal: true
          }
        }
      }
    }
  }
}
