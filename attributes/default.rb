default[:elasticsearch-chef][:url] = ""
default[:elasticsearch-chef][:version] = "0.1"
default[:elasticsearch-chef][:user] = "elastic"
default[:elasticsearch-chef][:group] = "elastic"

default[:elasticsearch-chef][:version_dir] = "/usr/local/elasticsearch-chef-#{node[:elasticsearch-chef][:version]}"
default[:elasticsearch-chef][:home_dir] = "/usr/local/elasticsearch-chef"

