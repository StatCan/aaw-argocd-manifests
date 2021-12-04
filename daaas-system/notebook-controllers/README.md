---
title: Notebook Controllers
date: 2021-11-21
tags:
  - argo
  - workflows
  - pipelines
  - cron
  - cronjob
  - cleanup
---

# Notebook Controllers

We use notebook controllers both to:

1. Add functionality, such as adding credentials or volume mounts
2. Apply custom networking, such as dynamic authorization policies to block endpoints.

Examples of `(1)` are the `goofys` and `minio-credential` injectors (in fact, likely any injector is in this category), and an example of `(2)` is the `auth-policy-checker`, which creates the Istio [`AuthorizationPolicy`](https://istio.io/latest/docs/reference/config/security/authorization-policy/) object on protected-b notebooks to block upload and download functionalities.
