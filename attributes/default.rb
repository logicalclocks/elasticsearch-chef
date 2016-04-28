include_attribute "kagent"
#include_attribute "ndb"
include_attribute "elasticsearch"

default.elastic.version               = "1.7.0"
default.elastic.jdbc_importer.version    = "1.7.3.0"
default.elastic.install_type          = "tarball"
default.elastic.checksum              = "6fabed2db09e1b88587df15269df328ecef33e155b3c675a2a6d2299bda09c95"
# http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/2.1.1.2/elasticsearch-jdbc-2.1.1.2-dist.zip
default.elastic.url                   = node.download_url + "/elasticsearch-#{node.elastic.version}.tar.gz"
default.elastic.user                  = "elastic"
default.elastic.group                 = "elastic"

default.elastic.port                  = "9200"

default.elastic.cluster_name          = "hops"
default.elastic.node_name             = "hopsworks"
default.elastic.rivers_enabled        = "true"

default.elastic.dir                   = "/usr/local"
default.elastic.version_dir           = "#{node.elastic.dir}/elasticsearch-#{node.elastic.version}"
default.elastic.home_dir              = "#{node.elastic.dir}/elasticsearch"
default.elastic.plugins_dir           = node.elastic.home_dir + "/plugins"

default.elastic.rivers                = %w{ parent child_pr child_ds dataset }

default.elastic.mysql_connector_url   = "#{download_url}/elasticsearch-jdbc-#{node.elastic.jdbc_importer.version}-dist.zip"
#default.elastic.mysql_connector_url   = "http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/#{node.elastic.jdbc_importer.version}/elasticsearch-jdbc-#{node.elastic.jdbc_river.version}-dist.zip"

default.elastic.limits.nofile         = "65535"
default.elastic.limits.memory_limit   = "100000"
default.elastic.limits_nproc          = '65536'

default.elastic.systemd               = "true"

default.elastic.memory                = "50m"
default.elastic.thread_stack_size     = "512k" 

node.default.java.jdk_version         = 7
