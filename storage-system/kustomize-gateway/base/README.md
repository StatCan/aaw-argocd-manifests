# Notes & Warnings

NOTE!!! Tolerations and nodeSelector are not respected from the values.yaml files.

All tolerations are set to `[]` in the kustomization.yaml file.

This is because we need the array to exist in order to apply subsequent Json6902 patches.
