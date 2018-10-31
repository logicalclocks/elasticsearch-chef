include_attribute "kagent"
include_attribute "elasticsearch"

default['elastic']['version']               = "6.2.3"
default['elastic']['install_type']          = "tarball"
default['elastic']['checksum']              = "01dd8dec5f0acf04336721e404bf4d075675a3acae9f2a9fdcdbb5ca11baca76"
default['elastic']['url']                   = node['download_url'] + "/elasticsearch-#{node['elastic']['version']}.tar.gz"
default['elastic']['user']                  = node['install']['user'].empty? ? "elastic" : node['install']['user']
default['elastic']['group']                 = node['install']['user'].empty? ? "elastic" : node['install']['user']

default['elastic']['port']                  = "9200"
default['elastic']['ntn_port']              = "9300" #elastic node to node communication port

default['elastic']['cluster_name']          = "hops"
default['elastic']['node_name']             = "hopsworks"

default['elastic']['dir']                   = node['install']['dir'].empty? ? "/usr/local" : node['install']['dir']
default['elastic']['version_dir']           = "#{node['elastic']['dir']}/elasticsearch-#{node['elastic']['version']}"
default['elastic']['home_dir']              = "#{node['elastic']['dir']}/elasticsearch"
default['elastic']['data_dir']              = "#{node['elastic']['dir']}/elasticsearch-data"

default['elastic']['plugins_dir']           = node['elastic']['home_dir'] + "/plugins"

default['elastic']['limits']['nofile']      = "65536"
default['elastic']['limits_nproc']          = '65536'

default['elastic']['default_kibana_index']  = "hopsdefault"

default['elastic']['systemd']               = "true"

default['elastic']['memory']['Xms']         = "256m"
default['elastic']['memory']['Xmx']         = "256m"

default['elastic']['thread_stack_size']     = "512k"


default['elastic']['pid_file']              = "/tmp/elasticsearch.pid"

# Kernel tuning
default['elastic']['kernel']['vm.max_map_count']      = "262144"


# Index management
# Whether to reindex the projects index. In case of changes in the index,
# set this attr to true. It will then be deleted and re-created so epipe can reindex it.
default['elastic']['projects']['reindex']   = "false"
