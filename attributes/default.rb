include_attribute "kagent"
include_attribute "elasticsearch"

default['elastic']['version']               = "7.2.0"
default['elastic']['install_type']          = "tarball"
default['elastic']['checksum']              = "4c77cfce006de44f4657469523c6305e2ae06b60021cabb4398c2d0a48e8920a"
default['elastic']['url']                   = node['download_url'] + "/elasticsearch-oss-#{node['elastic']['version']}-linux-x86_64.tar.gz"
default['elastic']['user']                  = node['install']['user'].empty? ? "elastic" : node['install']['user']
default['elastic']['elk-user']              = node['install']['user'].empty? ? "elkadmin" : node['install']['user']
default['elastic']['group']                 = node['install']['user'].empty? ? "elastic" : node['install']['user']
default['elastic']['elk-group']             = node['install']['user'].empty? ? "elkadmin" : node['install']['user']
default['elastic']['user-home']             = "/home/#{node['elastic']['user']}"
default['elastic']['elk-home']              = "/home/#{node['elastic']['elk-user']}"

default['elastic']['port']                  = "9200"
default['elastic']['ntn_port']              = "9300" #elastic node to node communication port

default['elastic']['cluster_name']          = "hops"
default['elastic']['master']                = "true"
default['elastic']['data']                  = "true"

# Data volume directories
default['elastic']['data_volume']['root_dir'] = "#{node['data']['dir']}/elasticsearch"
default['elastic']['data_volume']['data_dir'] = "#{node['elastic']['data_volume']['root_dir']}/elasticsearch-data"
default['elastic']['data_volume']['log_dir']  = "#{node['elastic']['data_volume']['root_dir']}/logs"

default['elastic']['dir']                   = node['install']['dir'].empty? ? "/usr/local" : node['install']['dir']
default['elastic']['version_dir']           = "#{node['elastic']['dir']}/elasticsearch-#{node['elastic']['version']}"
default['elastic']['home_dir']              = "#{node['elastic']['dir']}/elasticsearch"
default['elastic']['data_dir']              = "#{node['elastic']['dir']}/elasticsearch-data"
default['elastic']['config_dir']            = "#{node['elastic']['home_dir']}/config"
default['elastic']['log_dir']               = "#{node['elastic']['home_dir']}/logs"
default['elastic']['bin_dir']               = "#{node['elastic']['home_dir']}/bin"
default['elastic']['plugins_dir']           = "#{node['elastic']['home_dir']}/plugins"

default['elastic']['limits']['nofile']      = "65536"
default['elastic']['limits_nproc']          = '65536'

default['elastic']['systemd']               = "true"

default['elastic']['memory']['Xms']         = "1024m"
default['elastic']['memory']['Xmx']         = "1024m"
default['elastic']['cluster']['max_shards_per_node'] = "3000"

default['elastic']['thread_stack_size']     = "512k"


default['elastic']['pid_file']              = "/tmp/elasticsearch.pid"

# Kernel tuning
default['elastic']['kernel']['vm.max_map_count']      = "262144"


# Index management
# Whether to reindex the projects/featurestore index. In case of changes in the index,
# set this attr to true. It will then be deleted and re-created so epipe can reindex it.
default['elastic']['projects']['reindex']       = "false"
default['elastic']['featurestore']['reindex']   = "false"

# Metrics
default['elastic']['exporter']['version']       = "1.1.0"
default['elastic']['exporter']['url']           = "#{node['download_url']}/prometheus/elasticsearch_exporter-#{node['elastic']['exporter']['version']}.linux-amd64.tar.gz"
default['elastic']['exporter']['home']          = "#{node['elastic']['dir']}/elasticsearch_exporter-#{node['elastic']['exporter']['version']}.linux-amd64"
default['elastic']['exporter']['base_dir']      = "#{node['elastic']['dir']}/elasticsearch_exporter"

default['elastic']['exporter']['port']          = "9114"

default['elastic']['exporter']['flags']         = %w[--es.all
    --es.indices
    --es.shards
]

#OpenDistro Security Plugin
default['elastic']['opendistro']['version']                                         = "1.2.0.0"
default['elastic']['opendistro_security']['enabled']                                = "true"
default['elastic']['opendistro_security']['url']                                    = "#{node['download_url']}/opendistro_security-#{node['elastic']['opendistro']['version']}.zip"
default['elastic']['opendistro_security']['base_dir']                               = "#{node['elastic']['plugins_dir']}/opendistro_security"
default['elastic']['opendistro_security']['config_dir']                             = "#{node['elastic']['opendistro_security']['base_dir']}/securityconfig"
default['elastic']['opendistro_security']['tools_dir']                              = "#{node['elastic']['opendistro_security']['base_dir']}/tools"
default['elastic']['opendistro_security']['tools']['hash']                          = "#{node['elastic']['opendistro_security']['tools_dir']}/hash.sh"
default['elastic']['opendistro_security']['tools']['securityadmin']                 = "#{node['elastic']['opendistro_security']['tools_dir']}/securityadmin.sh"

default['elastic']['opendistro_security']['admin']['username']                      = "admin"
default['elastic']['opendistro_security']['admin']['password']                      = "adminpw"
default['elastic']['opendistro_security']['kibana']['username']                     = "kibanaserver"
default['elastic']['opendistro_security']['kibana']['password']                     = "kibanaserver"
default['elastic']['opendistro_security']['logstash']['username']                   = "logstash"
default['elastic']['opendistro_security']['logstash']['password']                   = "logstash"
default['elastic']['opendistro_security']['elastic_exporter']['username']           = "elastic_exporter"
default['elastic']['opendistro_security']['elastic_exporter']['password']           = "elastic_exporter"
default['elastic']['opendistro_security']['epipe']['username']                      = "epipeuser"
default['elastic']['opendistro_security']['epipe']['password']                      = "epipepassword"

default['elastic']['opendistro_security']['keystore']['type']                       = "JKS"
default['elastic']['opendistro_security']['keystore']['file']                       = "kstore.jks"
default['elastic']['opendistro_security']['keystore']['location']                   = "#{node['elastic']['config_dir']}/#{node['elastic']['opendistro_security']['keystore']['file']}"
default['elastic']['opendistro_security']['keystore']['password']                   = node['hopsworks']['master']['password']

default['elastic']['opendistro_security']['truststore']['type']                     = "JKS"
default['elastic']['opendistro_security']['truststore']['file']                     = "tstore.jks"
default['elastic']['opendistro_security']['truststore']['location']                 = "#{node['elastic']['config_dir']}/#{node['elastic']['opendistro_security']['truststore']['file']}"
default['elastic']['opendistro_security']['truststore']['password']                 = node['hopsworks']['master']['password']

default['elastic']['opendistro_security']['https']['enabled']                       = "true"
default['elastic']['opendistro_security']['kibana']['multitenancy']['enabled']      = "true"
default['elastic']['opendistro_security']['kibana']['index']                        = ".kibana"

default['elastic']['opendistro_security']['jwt']['enabled']                         = "true"
default['elastic']['opendistro_security']['jwt']['url_parameter']                   = "jt"
default['elastic']['opendistro_security']['jwt']['roles_key']                       = "roles"
default['elastic']['opendistro_security']['jwt']['subject_key']                     = "sub"
default['elastic']['opendistro_security']['jwt']['exp_ms']                          = "1800000"

default['elastic']['opendistro_security']['roles']['data_owner']['role_name']       = 'data_owner'
default['elastic']['opendistro_security']['roles']['data_scientist']['role_name']   = 'data_scientist'

default['elastic']['opendistro_security']['audit']['enable_rest']                   = "true"
default['elastic']['opendistro_security']['audit']['enable_transport']              = "false"
default['elastic']['opendistro_security']['audit']['type']                          = "internal_elasticsearch"
default['elastic']['opendistro_security']['audit']['threadpool']['size']            = 10
default['elastic']['opendistro_security']['audit']['threadpool']['max_queue_len']   = 100000


default['elastic']['epipe']['search_index']                                         = "projects"
default['elastic']['epipe']['app_provenance_index']                                 = "app_provenance"
default['elastic']['epipe']['file_provenance_index_pattern']                        = "*__file_prov"
default['elastic']['epipe']['featurestore_index']                                   = "featurestore"
