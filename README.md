# Docker ELK stack

[![Join the chat at https://gitter.im/deviantony/docker-elk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/deviantony/docker-elk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Elastic Stack version](https://img.shields.io/badge/ELK-5.5.0-blue.svg?style=flat)](https://github.com/deviantony/docker-elk/issues/146)

Run the latest version of the ELK (Elasticsearch, Logstash, Kibana) stack with Docker and Docker Compose.

It will give you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch
and the visualization power of Kibana.

Based on the official Docker images:

* [elasticsearch](https://github.com/elastic/elasticsearch-docker)
* [logstash](https://github.com/elastic/logstash-docker)
* [kibana](https://github.com/elastic/kibana-docker)

**Note**: Other branches in this project are available:

* ELK 5 with X-Pack support: https://github.com/deviantony/docker-elk/tree/x-pack
* ELK 5 in Vagrant: https://github.com/deviantony/docker-elk/tree/vagrant
* ELK 5 with Search Guard: https://github.com/deviantony/docker-elk/tree/searchguard

## Contents

1. [Requirements](#requirements)
   * [Host setup](#host-setup)
   * [SELinux](#selinux)
2. [Getting started](#getting-started)
   * [Bringing up the stack](#bringing-up-the-stack)
3. [Configuration](#configuration)
   * [How can I tune the Kibana configuration?](#how-can-i-tune-the-kibana-configuration)
   * [How can I tune the Logstash configuration?](#how-can-i-tune-the-logstash-configuration)
   * [How can I tune the Elasticsearch configuration?](#how-can-i-tune-the-elasticsearch-configuration)
   * [How can I scale out the Elasticsearch cluster?](#how-can-i-scale-up-the-elasticsearch-cluster)
4. [Storage](#storage)
   * [How can I persist Elasticsearch data?](#how-can-i-persist-elasticsearch-data)
5. [Extensibility](#extensibility)
   * [How can I add plugins?](#how-can-i-add-plugins)
   * [How can I enable the provided extensions?](#how-can-i-enable-the-provided-extensions)
6. [JVM tuning](#jvm-tuning)
   * [How can I specify the amount of memory used by a service?](#how-can-i-specify-the-amount-of-memory-used-by-a-service)
   * [How can I enable a remote JMX connection to a service?](#how-can-i-enable-a-remote-jmx-connection-to-a-service)
7. [Deleting Data](#deleting-data)
   * [How can I delete all the data?](#how-can-i-delete-all-the-data)
8. [Changing passwords](#changing-passwords)
   * [How can I change all the passwords?](#how-can-i-change-all-the-passwords)
9. [Changing field types](#changing-field-types)
10. [Usefull operations](#usefull-operations)

## Requirements

### Host setup

1. Install [Docker](https://www.docker.com/community-edition#/download) version **1.10.0+**
2. Install [Docker Compose](https://docs.docker.com/compose/install/) version **1.6.0+**
3. Clone this repository

### SELinux

On distributions which have SELinux enabled out-of-the-box you will need to either re-context the files or set SELinux
into Permissive mode in order for docker-elk to start properly. For example on Redhat and CentOS, the following will
apply the proper context:

```bash
$ chcon -R system_u:object_r:admin_home_t:s0 docker-elk/
```

## Usage

### Bringing up the stack

Start the ELK stack using `docker-compose`:

```bash
$ docker-compose up
```

You can also choose to run it in background (detached mode):

```bash
$ docker-compose up -d
```

Give Kibana about 2 minutes to initialize, then access the Kibana web UI by hitting
[http://localhost:5601](http://localhost:5601) with a web browser and use the following default credentials to login:

* user: *elastic*
* password: *changeme*

Refer to the Elastic documentation for a list of built-in users: [Setting Up User
Authentication](https://www.elastic.co/guide/en/x-pack/current/setting-up-authentication.html#built-in-users)

By default, the stack exposes the following ports:
* 5000: Logstash TCP input.
* 9191: Logstash HTTP input
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 5601: Kibana

**WARNING**: If you're using `boot2docker`, you must access it via the `boot2docker` IP address instead of `localhost`.

**WARNING**: If you're using *Docker Toolbox*, you must access it via the `docker-machine` IP address instead of
`localhost`.

Now that the stack is running, you will want to inject some log entries. 
One way to do it is using curl:
```bash
$ curl -H "content-type: application/json" -XPOST 'http://127.0.0.1:9191/log' -d '{
"message": "This is the first log to kibana.",
"ENV": "dev",
"severity": "severity",
"timestamp": "2017-05-04",
"version": "version"
}'
```


## Configuration

**NOTE**: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the
configuration of a component.

### How can I tune the Kibana configuration?

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

It is also possible to map the entire `config` directory instead of a single file.

### How can I tune the Logstash configuration?

The Logstash configuration is stored in `logstash/config/logstash.yml`.

It is also possible to map the entire `config` directory instead of a single file, however you must be aware that
Logstash will be expecting a
[`log4j2.properties`](https://github.com/elastic/logstash-docker/tree/master/build/logstash/config) file for its own
logging.

### How can I tune the Elasticsearch configuration?

The Elasticsearch configuration is stored in `elasticsearch/config/elasticsearch.yml`.

You can also specify the options you want to override directly via environment variables:

```yml
elasticsearch:

  environment:
    network.host: "_non_loopback_"
    cluster.name: "my-cluster"
```

### How can I scale out the Elasticsearch cluster?

Follow the instructions from the Wiki: [Scaling out
Elasticsearch](https://github.com/deviantony/docker-elk/wiki/Elasticsearch-cluster)

## Storage

### How can I persist Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on
your Docker host. Update the `elasticsearch` service declaration to:

```yml
elasticsearch:

  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
```

This will store Elasticsearch data inside `/path/to/storage`.

**NOTE:** beware of these OS-specific considerations:
* **Linux:** the [unprivileged `elasticsearch` user][esuser] is used within the Elasticsearch image, therefore the
  mounted data directory must be owned by the uid `1000`.
* **macOS:** the default Docker for Mac configuration allows mounting files from `/Users/`, `/Volumes/`, `/private/`,
  and `/tmp` exclusively. Follow the instructions from the [documentation][macmounts] to add more locations.

[esuser]: https://github.com/elastic/elasticsearch-docker/blob/016bcc9db1dd97ecd0ff60c1290e7fa9142f8ddd/templates/Dockerfile.j2#L22
[macmounts]: https://docs.docker.com/docker-for-mac/osxfs/


## Extensibility

### How can I add plugins?

To add plugins to any ELK component you have to:

1. Add a `RUN` statement to the corresponding `Dockerfile` (eg. `RUN logstash-plugin install logstash-filter-json`)
2. Add the associated plugin code configuration to the service configuration (eg. Logstash input/output)
3. Rebuild the images using the `docker-compose build` command

### How can I enable the provided extensions?

A few extensions are available inside the [`extensions`](extensions) directory. These extensions provide features which
are not part of the standard Elastic stack, but can be used to enrich it with extra integrations.

The documentation for these extensions is provided inside each individual subdirectory, on a per-extension basis. Some
of them require manual changes to the default ELK configuration.

## JVM tuning

### How can I specify the amount of memory used by a service?

By default, both Elasticsearch and Logstash start with [1/4 of the total host
memory](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/parallel.html#default_heap_size) allocated to
the JVM Heap Size.

The startup scripts for Elasticsearch and Logstash can append extra JVM options from the value of an environment
variable, allowing the user to adjust the amount of memory that can be used by each component:

| Service       | Environment variable |
|---------------|----------------------|
| Elasticsearch | ES_JAVA_OPTS         |
| Logstash      | LS_JAVA_OPTS         |

To accomodate environments where memory is scarce (Docker for Mac has only 2 GB available by default), the Heap Size
allocation is capped by default to 256MB per service in the `docker-compose.yml` file. If you want to override the
default JVM configuration, edit the matching environment variable(s) in the `docker-compose.yml` file.

For example, to increase the maximum JVM Heap Size for Logstash:

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Xmx1g -Xms1g"
```

### How can I enable a remote JMX connection to a service?

As for the Java Heap memory (see above), you can specify JVM options to enable JMX and map the JMX port on the docker
host.

Update the `{ES,LS}_JAVA_OPTS` environment variable with the following content (I've mapped the JMX service on the port
18080, you can change that). Do not forget to update the `-Djava.rmi.server.hostname` option with the IP address of your
Docker host (replace **DOCKER_HOST_IP**):

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=18080 -Dcom.sun.management.jmxremote.rmi.port=18080 -Djava.rmi.server.hostname=DOCKER_HOST_IP -Dcom.sun.management.jmxremote.local.only=false"
```

## Deleting Data

### How can I delete all the data?

You can run this command on the elastic docker image:
```bash
curl -XDELETE 'http://localhost:9200/logstash-*'
```

## Changing Passwords

### How can I change all the passwords?

First update the file:
* In the file `./logstash/config/logstash.yml` add a line `xpack.monitoring.elasticsearch.password: logstashpassword`

Choose one option:
* Change the passwords in the .env file
* Run the command 
  ``` bash
  $ KIBANA_USER_PASSWORD=kibanapassword \
  LOGSTASH_SYSTEM_USER_PASSWORD=logstashpassword \
  ELASTIC_USER_PASSWORD=elasticpassword \
  docker-compose up -d
  ```

## Changing field types

In order to change the field type you need to:
1. Create an index with a default mapping containing the field with the wanted type
  ```bash
  $ curl -XPUT 'localhost:9200/new-index-name?pretty' -H 'Content-Type: application/json' -d'
  {
    "mappings": {
      "_default_": { 
        "properties": { 
          "field-to-change": { "type": "text" }  
        }
      }
    }
  }
  ' -u elastic:changeme
  ```

2. Move the data from the bad index to the new index
  ```bash
  $ curl -XPOST 'localhost:9200/_reindex?pretty' -H 'Content-Type: application/json' -d'
  {
    "source": {
      "index": "source-index"
    },
    "dest": {
      "index": "new-index-name",
      "version_type": "internal"
    }
  }' -u elastic:changeme
  ```

3. Delete the old index
  ```bash
  $ curl -XDELETE 'http://localhost:9200/source-index' -u elastic:changeme
  ```

## Usefull operations
* Check the disk usage: 
  ```
  curl -s 'localhost:9200/_cat/allocation?v'
  ```
* Change the disk low/high watermarks:
  ```
  curl -XPUT 'localhost:9200/_cluster/settings' -d
  '{
      "transient": {  
        "cluster.routing.allocation.disk.watermark.low": "90%"    
      }
  }'
  ```
  ```
  curl -XPUT 'localhost:9200/_cluster/settings' -d
  '{
      "transient": {  
        "cluster.routing.allocation.disk.watermark.high": "90%"    
      }
  }'
  ```
  If you want your configuration changes to persist upon cluster restart, replace `transient` with `persistent`
  Percentage values refer to used disk space, while byte values refer to free disk space.

* Showing `UNASSIGNED` shards: 
  ```
  curl 'localhost:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason' | grep 'UNASSIGNED'
  ```
  Columns: `index`, `shard id`, `shard type` (primary/replica), `state`, `reason for state`
  Reasons explanations: https://www.elastic.co/guide/en/elasticsearch/reference/5.4/cat-shards.html
* Showing the reason for `UNASSIGNED` shard:
  ```
  curl -s 'localhost:9200/_cluster/allocation/explain' -d '{"index":"index-name","shard":4,"primary":true}'
  ```
* Re-assigning one singe shard: 
  ```
  curl -XPOST 'localhost:9200/_cluster/reroute?retry_failed=true&pretty'
  ```
  If you have many shards, run this A LOT!

  This PR should fix it: https://github.com/elastic/elasticsearch/pull/25888

* Solving `UNASSIGNED` shards issues: https://www.datadoghq.com/blog/elasticsearch-unassigned-shards/#reason-5-low-disk-watermark
* Get the elasticsearch nodes details: 
  ```
  curl `localhost:9200/_nodes`
  ```
* Get the elasticsearch cluster details (including the cluster.name):
  ```
  curl 'localhost:9200/_cluster/health'
  ```
  Status explained:
  * `green`: All primary and replica shards are active.
  * `yellow`: All primary shards are active, but not all replica shards are active.
  * `red`: Not all primary shards are active

  (Source: https://www.elastic.co/guide/en/elasticsearch/guide/current/cluster-health.html)

* Change the default number of shards for new indices:
  http://spuder.github.io/2015/elasticsearch-default-shards/

* Shrink existing index (number of shards):
  https://www.elastic.co/guide/en/elasticsearch/reference/5.4/indices-shrink-index.html
