include_attribute "kagent"
include_attribute "elasticsearch"

default['elastic']['version']               = "2.4.1"
default['elastic']['install_type']          = "tarball"
default['elastic']['checksum']              = "23a369ef42955c19aaaf9e34891eea3a055ed217d7fbe76da0998a7a54bbe167"
default['elastic']['url']                   = node['download_url'] + "/elasticsearch-#{node['elastic']['version']}.tar.gz"
default['elastic']['user']                  = node['install']['user'].empty? ? "elastic" : node['install']['user']
default['elastic']['group']                 = node['install']['user'].empty? ? "elastic" : node['install']['user']

default['elastic']['port']                  = "9200"

default['elastic']['cluster_name']          = "hops"
default['elastic']['node_name']             = "hopsworks"

default['elastic']['dir']                   = node['install']['dir'].empty? ? "/usr/local" : node['install']['dir']
default['elastic']['version_dir']           = "#{node['elastic']['dir']}/elasticsearch-#{node['elastic']['version']}"
default['elastic']['home_dir']              = "#{node['elastic']['dir']}/elasticsearch"
default['elastic']['plugins_dir']           = node['elastic']['home_dir'] + "/plugins"

default['elastic']['limits']['nofile']         = "65535"
default['elastic']['limits']['memory_limit']   = "100000"
default['elastic']['limits_nproc']          = '65536'

default['elastic']['systemd']               = "true"

default['elastic']['memory']                = "50m"
default['elastic']['thread_stack_size']     = "512k"


default['elastic']['pid_file']              = "/tmp/elasticsearch.pid"


