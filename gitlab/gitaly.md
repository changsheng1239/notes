# Gitaly

**Reference: [Gitaly doc](https://docs.gitlab.com/ee/administration/gitaly/index.html)**

## Introduction

---

![https://docs.gitlab.com/ee/administration/gitaly/img/praefect_architecture_v12_10.png](https://docs.gitlab.com/ee/administration/gitaly/img/praefect_architecture_v12_10.png)

## Clusters

Gitaly Cluster consists of multiple components:

-   [Load balancer](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#load-balancer) for distributing requests and providing fault-tolerant access to Praefect nodes.
-   [Praefect](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#praefect) nodes for managing the cluster and routing requests to Gitaly nodes.
-   [PostgreSQL database](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#postgresql) for persisting cluster metadata and [PgBouncer](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#use-pgbouncer), recommended for pooling Praefect’s database connections.
-   Gitaly nodes to provide repository storage and Git access

## Features

Gitaly Cluster provides the following features:

-   [Distributed reads](https://docs.gitlab.com/ee/administration/gitaly/index.html#distributed-reads) among Gitaly nodes.
-   [Strong consistency](https://docs.gitlab.com/ee/administration/gitaly/index.html#strong-consistency) of the secondary replicas.
-   [Replication factor](https://docs.gitlab.com/ee/administration/gitaly/index.html#replication-factor) of repositories for increased redundancy.
-   [Automatic failover](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#automatic-failover-and-primary-election-strategies) from the primary Gitaly node to secondary Gitaly nodes.
-   Reporting of possible [data loss](https://docs.gitlab.com/ee/administration/gitaly/praefect.html#check-for-data-loss) if replication queue is non-empty.

Follow the [Gitaly Cluster epic](https://gitlab.com/groups/gitlab-org/-/epics/1489) for improvements including [horizontally distributing reads](https://gitlab.com/groups/gitlab-org/-/epics/2013)

## Requirements

The minimum recommended configuration for a Gitaly Cluster requires:

-   1 load balancer
-   1 PostgreSQL server (PostgreSQL 11 or newer)
-   3 Praefect nodes
-   3 Gitaly nodes (1 primary, 2 secondary)