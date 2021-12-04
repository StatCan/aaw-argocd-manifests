---
title: Profiles Controller
date: 2021-11-21
tags:
  - kubeflow
  - profile
  - controller
  - namespace
---

The [`kubeflow-controller`](https://github.com/StatCan/aaw-kubeflow-controller) was our original mechanism for adding per-profile resources across namespaces. We regret its original design, as it became a large, monolithic system, which made it progressively harder to test and develop.

We are moving to a refactored design, the [`profiles-controller`](https://github.com/StatCan/aaw-kubeflow-profiles-controller), which factors the controllers into separate modules which execute independently. The monolithic `kubeflow-controller` will eventually be removed.
