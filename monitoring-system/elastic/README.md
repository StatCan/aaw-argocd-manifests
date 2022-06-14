# Introduction
The elastic component of the AAW monitoring-system is used primarily for the aggregation, searching and visualization of logs produced within the AAW cluster(s). An independent elastic stack is setup for each cluster and accessed primarily via Kibana:

- https://monitoring-kibana.aaw-dev.cloud.statcan.ca/
- https://monitoring-kibana.aaw.cloud.statcan.ca/

The other component for monitoring the AAW cluster(s) is the Prometheus-Grafana stack (deployed as part of the [statcan-kubernetes-core-platform](https://github.com/StatCan/terraform-statcan-kubernetes-core-platform/blob/main/prometheus.tf), which is focused on the collection of metrics.

# Architecture

The elastic stack is made up of a number of components, which are described below. Primarily they are deployed with ArgoCD, so you can visualize the many pieces of the monitoring-system here:

- https://daaas-system-argocd.aaw-dev.cloud.statcan.ca/applications/monitoring-system
- https://daaas-system-argocd.aaw.cloud.statcan.ca/applications/monitoring-system

## Components
 - [Elasticsearch](https://www.elastic.co/what-is/elasticsearch)

   The main component of the system, elasticsearch indexes, stores and searches the data. The data is stored in [lucene](https://lucene.apache.org/) indexes and made accessible via a custom JSON REST interface. 

 - [Kibana](https://www.elastic.co/what-is/kibana)

   A UI for accessing the elasticserach data, it has built in visualization tools as well as a management interface for managing the elasticsearch cluster.

 - [Beats](https://www.elastic.co/beats/)
   
   There are a number of modules that are named 'beats' that are used to ingest specific types of data and send it to elasticsearch.

   - [Heartbeat](https://www.elastic.co/beats/heartbeat)

     The heartbeat module is implemented in the aaw clusters, it is used to check for uptime of services. This data is stored in elasticsearch and kibana is used to review the results.

 - [Fluentd](https://docs.fluentd.org/)

   A tool that isn't built by Elastic, it is an alternative to their logstash product. It is used to ingest log files and is implemented in the aaw cluster as part of a [core terraform module](https://github.com/StatCan/terraform-kubernetes-fluentd).

## Data Flows & Ingresses

 The elasticsearch, kibana and beat modules are deployed by ArgoCD from the monitoring-system namespace. The Kibana interface is behind the istio authenticated gateway so that it can be safely accessed by users, while the elasticsearch services are only accessable from within the cluster, which is all that is necessary for it's job of data ingestion.
 
 The main source of data ingestion is done by Fluentd, which deploys an agent pod on each node in the cluster in the fluentd-system namespace. The agent periodically scrapes the logs from all pods in all configured namespaces on it's node and sends them to elasticsearch directly.

 Each namespace has a fluentd-config configmap, this is used to determine how the log data is scrapped from the namespace. The default configuration is setup like this:

```
<match **>
  @type default
</match>
 ```

The way this config works is all logs are matched and they are sent to the 'default' plugin. The 'default' plugin is defined int he fluentd-config in the fluentd-system and in our case, sends the data to elasticsearch.

# Administrative tasks

## Elasticserach REST API

The REST API is actually the method that Elasticsearch uses to serve the data that it stores, but it is also used for administration of the system. While Kibana is useful to manage many settings it does not have all possible functionality.

The REST endpoints accept a JSON payload that is described in the official elasticsearch [documentation]((https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html)), some simple examples are below using various access methods.

> Credentials will need to be provided when accessing the REST API, you may use your own credentials or if necessary the elastic build in admin account can be used.

> The elastic system password can be extracted from the kubernetes secret using: ``` kubectl -n monitoring-system get secret elastic-monitoring-es-elastic-user '--template={{ .data.elastic }}' | base64 --decode ```

- Access the REST interface via Kibana (as the logged in user) under *Management* > *Dev Tools*

  ```
  PUT /_cluster/settings
  {
  "transient": { 
    "cluster.routing.allocation.enable": null 
    },
  "persistent": { 
    "cluster.routing.allocation.enable": null 
    }
  }
  ```

- Via the *elastic-monitoring-es-http* kubernetes service endpoint
  > note that the elastic http service does not have an istio virtual service, so this endpoint is only accessible from within the cluster (i.e. kubeflow container / another pod), and will not resolve from your Windows or Linux VM. 

  ```
  curl -u elastic:asdf --insecure -XPUT 'elastic-monitoring-es-http.monitoring-system.svc.cluster.local:9200/_cluster/settings?pretty' -H 'Content-Type: application/json' -d'
  {
    "transient": { 
      "cluster.routing.allocation.enable": null 
      },
    "persistent": { 
      "cluster.routing.allocation.enable": null 
      }
  }
  '
  ```

- From the shell within one of the elastic-monitoring-es-nodes-X pods themselves!

  ```bash
  curl -u elastic:asdfasdf -XGET 'http://localhost:9200/_cluster/health?pretty'
  {
    "cluster_name" : "elastic-monitoring",
    "status" : "yellow",
    "timed_out" : false,
    "number_of_nodes" : 3,
    "number_of_data_nodes" : 3,
    "active_primary_shards" : 67,
    "active_shards" : 121,
    "relocating_shards" : 2,
    "initializing_shards" : 0,
    "unassigned_shards" : 13,
    "delayed_unassigned_shards" : 0,
    "number_of_pending_tasks" : 0,
    "number_of_in_flight_fetch" : 0,
    "task_max_waiting_in_queue_millis" : 0,
    "active_shards_percent_as_number" : 90.29850746268657
  }
  ```

## Users and security groups

There is a comprehensive system of users and roles that allow fine grained to data, and while it can be done via the Kibana interface it is easier to script for a large number of users.

Generating a new API key using the elastic API, the key will be returned if successful so make sure to copy it (it is not accessible later on).
```
POST /_security/api_key
{
  "name": "my_app-writer",
  "role_descriptors": { 
    "role-a": {

    "cluster" : [
      "monitor"
    ],
    "indices" : [
      {
        "names" : [
          "index-*"
        ],
        "privileges" : [
          "create_index",
          "create_doc",
          "view_index_metadata",
          "write",
          "auto_configure"
        ],
        "allow_restricted_indices" : false
      }
    ]
    }
  },
  "metadata": {
    "application": "my_app",
    "environment": "dev"
  }
}

```

How to create a user using the *user* API:
```
POST /_security/user/brendan.gadd
{
  "password" : "asdfasdfasd",
  "roles" : [ "superuser" ],
  "full_name" : "Brendan Gadd",
  "email" : "brendan.gadd@statcan.gc.ca"
}
```

## Development tasks


## Maintenance tasks

### Out of space
A common issue when data ingestion increases and retention settings allow the data indexes to grow too large. Elasticsearch will start to flip indexes over to read-only when approaching 85-90% of the volume capacity. If data continues to increase further this will often cause Kibana to become unresponsive and require resolution via the REST API.

The elastic nodes log files will have some messages similar to this:
```
"WARN", "message":"high disk watermark [90%] exceeded on [jKuFSyLmQGaNwMgXOTAxTA][elastic-monitoring-es-nodes-0][/usr/share/elasticsearch/data] free: 38.9gb[7.7%], shards will be relocated away from this node; currently relocating away shards totalling [0] bytes; the node is expected to continue to exceed the high disk watermark when these relocations are complete"
```

To resolve this issue you will need to review the existing indexes, delete the oldest / largest indexes to restore space, then reset the setting so that the remaining indexes are writable again.

```bash
elasticsearch@elastic-monitoring-es-nodes-0:~$ curl -u elastic:asdf -XGET 'http://localhost:9200/_cat/indices?pretty'
yellow open fluentd-logs-default-2022.06.07       w1qbY6aUSqmaCk073DQI9w 1 1         0 0    225b    225b
green  open fluentd-logs-system-2022.05.31        ZkxrzvXlT9CU-Cl3N05UJA 1 1  64950142 0  28.6gb  14.2gb
green  open fluentd-logs-system-2022.06.01        7WGuNGunQAuERmpDuftKRQ 1 1 112030549 0  50.2gb    25gb
green  open fluentd-logs-default-2022.05.24       ssTXZ0ARSYuQTZDlSfyj9A 1 1  30735615 0  10.6gb   5.3gb
green  open fluentd-logs-system-2022.05.25        w0lmn-3MRfSzob9T7UVdSQ 1 1  56258807 0  24.8gb  12.3gb
green  open fluentd-logs-default-2022.06.01       Fau7CRMrQZqojF0GSwy4fg 1 1 124372623 0  55.7gb  27.7gb

elasticsearch@elastic-monitoring-es-nodes-0:~$ curl -u elastic:asdf -XDELETE 'http://localhost:9200/fluentd-logs-system-2022.05.22'
{"acknowledged":true}

elasticsearch@elastic-monitoring-es-nodes-0:~$ curl -u elastic:asdf -XPUT 'http://localhost:9200/_all/_settings' -H "Content-Type: application/json" -d'
{
  "index.blocks.read_only_allow_delete": null
}'
{"acknowledged":true}
```