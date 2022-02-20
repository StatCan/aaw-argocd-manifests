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
              version: std.extVar('targetRevision'),
              overlay: "base"
              # Example, if you need a dev/prod split, use
              # > overlay: "overlays/" + std.extVar('targetRevision')
              # and have a dev and prod overlay in aaw-kubeflow-manifests.
            },
            {
              app: "kubeflow-roles",
              folder: "common",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "oidc-authservice",
              folder: "common",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "knative",
              folder: "common",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "admission-webhook",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "centraldashboard",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "jupyter-web-app",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "katib",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "kfserving",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "mpi-job",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "mxnet-job",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "notebook-controller",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "pipeline",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "profiles",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "pytorch-job",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "tr-training",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "seldon",
              folder: "apps",
              version: std.extVar('targetRevision'),
              overlay: "base"
            },
            {
              app: "spark",
              folder: "apps",
              version: std.extVar('targetRevision'),
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
          targetRevision: "{{version}}"
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
