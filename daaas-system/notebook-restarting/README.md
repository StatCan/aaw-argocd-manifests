## Purpose
https://github.com/StatCan/daaas/issues/957

This is a weekly cronjob specification alongside basic k8s rbac to facilitate the restart of user workloads.
For quick deployment and iteration, currently I am building and pushing the image in [aaw-contrib-containers](https://github.com/StatCan/aaw-contrib-containers/tree/feat-notebook-restart/notebook-restart) inside my personal branch.
Once image is confirmed working and behaving move it to a better github repository.


## Requirements
A token created in the ACR that has `read/metadata` permissions on the images pushed by [aaw-kubeflow-containers](https://github.com/StatCan/aaw-kubeflow-containers/blob/189e823e064429e2a3d056d97c2cd64f15bbd228/.github/workflows/build_push.yaml#L68)

A kubernetes secret in the cluster under the `notebook-cleanup-system` namespace named `acr-metadata-read-secret` with entries for username and password.

Any other relevant information can be found in the [readmes](https://github.com/StatCan/aaw-contrib-containers/tree/feat-notebook-restart/notebook-restart#patch-notebook-sts) for this specific image.

This muust be ran with the argument `execute` to not invoke a dry run. For now we are doing dry-runs only