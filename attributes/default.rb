include_attribute "kagent"
include_attribute "ndb"
include_attribute "elasticsearch"

default.elastic.version               = "1.7.3"
default.elastic.jdbc_importer.version    = "1.7.3.0"
default.elastic.install_type          = "tarball"
#default.elastic.checksum              = "1713b7e1f6511f89d72b1df018bdf696bd01008c"
default.elastic.checksum              = "af517611493374cfb2daa8897ae17e63e2efea4d0377d316baa351c1776a2bca"
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

default.elastic.ulimit_files          = "65535"
default.elastic.ulimit_memlock        = "65535"

default.elastic.systemd               = "true"

default.elastic.memory                = "123m"
default.elastic.thread_stack_size     = "512k" 

node.default.java.jdk_version         = 7
