---
date: 2021-11-21
tags:
  - argo
  - workflows
  - pipelines
  - cron
  - cronjob
  - cleanup
---

# Gatekeeper Policies & Constraints

The [Gatekeeper Policies](https://github.com/StatCan/gatekeeper-policies/) repo is a collection of [ConstraintTemplate](https://open-policy-agent.github.io/gatekeeper/website/docs/constrainttemplates/)s, which are instatiated in the (private) [Gatekeeper Constraints Repo](https://github.com/StatCan/aaw-gatekeeper-constraints).

**NOTE: Gatekeeper has a global configmap of all resources it can watch. [Example](https://github.com/StatCan/gatekeeper-policies/blob/master/gatekeeper-opa-sync.yaml). If you add policies/constraints you may need to edit this too.**

@EXTERNAL: https://raw.githubusercontent.com/StatCan/gatekeeper-policies/master/README.md
