default[:elastic][:version] = "1.5.0"
default[:elastic][:url] = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{node[:elastic][:version]}.tar.gz"
default[:elastic][:checksum] = "acf572c606552bc446cceef3f8e93814a363ba0d215b323a2864682b3abfbe45"
default[:elastic][:user] = "elastic"
default[:elastic][:group] = "elastic"

default[:elastic][:version_dir] = "/usr/local/elasticsearch-#{node[:elastic][:version]}"
default[:elastic][:home_dir] = "/usr/local/elasticsearch"
