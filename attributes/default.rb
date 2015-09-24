include_attribute "kagent"

node.override[:elastic][:version]         = "1.7.1"
default[:elastic][:url]                   = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{node[:elastic][:version]}.tar.gz"
#default[:elastic][:url]                   = node[:download_url] + "/elasticsearch-#{node[:elastic][:version]}.tar.gz"
default[:elastic][:user]                  = "elastic"
default[:elastic][:group]                 = "elastic"

default[:elastic][:cluster_name]          = "hops"
default[:elastic][:node_name]             = "hopsworks"

default[:elastic][:version_dir]           = "/usr/local/elasticsearch-#{node[:elastic][:version]}"
default[:elastic][:home_dir]              = "/usr/local/elasticsearch"

default[:elastic][:mysql_connector_url]   = "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz"

#default[:elastic][:jdbc_river][:version] = "1.5.0.5"
default[:elastic][:jdbc_river][:version]  = "1.7.0.1"
