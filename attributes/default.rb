include_attribute "kagent"
include_attribute "ndb"

node.override[:elastic][:version]         = "1.7.1"
default[:elastic][:url]                   = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{node[:elastic][:version]}.tar.gz"
#default[:elastic][:url]                   = node[:download_url] + "/elasticsearch-#{node[:elastic][:version]}.tar.gz"
default[:elastic][:user]                  = "elastic"
default[:elastic][:group]                 = "elastic"

default[:elastic][:cluster_name]          = "hops"
default[:elastic][:node_name]             = "hopsworks"

default[:elastic][:version_dir]           = "/usr/local/elasticsearch-#{node[:elastic][:version]}"
default[:elastic][:home_dir]              = "/usr/local/elasticsearch"
default[:elastic][:plugins_dir]           = node[:elastic][:home_dir] + "/plugins"

default[:elastic][:scripts]               = %w{ parent.sh child_pr.sh child_ds.sh dataset.sh test.sh }

#default[:elastic][:mysql_connector_url]   = "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz"

default[:elastic][:jdbc_river][:version]  = "1.7.1.0"

default[:elastic][:mysql_connector_url]   = "http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/#{node[:elastic][:jdbc_river][:version]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}-dist.zip"

