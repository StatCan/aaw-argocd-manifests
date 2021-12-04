---
title: Network Policies
date: 2021-11-21
tags:
  - networking
  - network policies
  - traffic
---

This repo, which is private, points specifically to **system** resources, such as Artifactory, the MinIO systems, and kubernetes controllers, to allow the system to function. It is a flat repo of network policies, with a dev/prod split done with two branches and `kustomization.yaml` files to include/exclude network policies depending on the environment.

**See also:**
- The [namespace-controller](https://github.com/StatCan/namespace-controller/blob/main/cmd/network.go) for the full set of default policies
- The [profiles-controller](https://github.com/StatCan/aaw-kubeflow-profiles-controller/blob/main/cmd/network.go) *also* creates network policies in kubeflow-profile namespaces

# Network Policies

[Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) are a Layer 4 (transport layer) firewall tool for managing flow between pods/namespaces based on labels/selectors and ip ranges. When combined with the [immutable label contraints](https://github.com/StatCan/gatekeeper-policies/blob/a52197c51e99799e0ac9824a503b6eb1ed7442dc/pod-security-policy/metadata-restrictions/template.yaml#L72-L84) this enables parts of the protected-b implementation, by allowing policies to apply selectively to a `data.statcan.gc.ca/classification` label, which may be either `unlcassified` or `protected-b`.

**You typically always have a matching `Ingress` and `Egress` NetworkPolicy in the recieving and sending namespaces (respectively). The senders are often (but not always) Notebooks, which you should refer to the profiles-controller for more on.**

# Default per-namespace Network Policies

## Default-Deny + Allow-Same-Namespace

The philosophy in the AAW is "Default Deny; explicit Allow". There is a [`namespace-controller`](https://github.com/StatCan/namespace-controller/blob/main/cmd/network.go) which creates a few default policies; among which is [`default-deny`](https://github.com/StatCan/namespace-controller/blob/96f7f1ad2d90cbd24958104211b30d9b86c38d85/cmd/network.go#L132-L145) along with `allow-same-ns` for allowing traffic in the namespace (among non-protected-b pods).

## All Kubeflow Profiles are configured by the `profiles-controller`

The [profiles-controller](https://github.com/StatCan/aaw-kubeflow-profiles-controller/blob/main/cmd/network.go) *also* creates network policies in kubeflow-profile namespaces. For example, every kubeflow profile namespace will get a NetworkPolicy added to allow notebooks to talk to Artifactory, as well as rules to talk to Protected-B and non-protected-b MinIO.

# Implementation & Known Issues

## IPTables are slow

At the time of writing the [Azure-NPM](https://github.com/Azure/azure-container-networking/blob/master/docs/npm.md) is `iptables` based, which has led to [serious performance issues](https://github.com/StatCan/daaas/issues/680#issuecomment-974277460). Some alternative implementations of NetworkPolicies use eBPF, which claim to offer better performance.

## Lots of Network Policies

Network Policies are a namespaced resource, which means that, when creating `N` policies in `M` Kubeflow-Profile namespaces, you get `N×M` policies, which can result in slow network-policy reconciliation times as well as performance issues reconfiguring the firewalls (as mentioned above). One possible solution for this issue is to explore non-standard alternatives such as Clilium's [`CiliunClusterwideNetworkPolicy`s](https://docs.cilium.io/en/v1.8/concepts/kubernetes/policy/#ciliumclusterwidenetworkpolicy), which would avoid this issue. It would also remove the need for two kubernetes controllers, `namespace-controller --network` and `profiles-controller --network`.

