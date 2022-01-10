include_attribute "kagent"

default['elastic']['opensearch']['version'] = "1.2.3"
default['elastic']['version']               = node['elastic']['opensearch']['version']
default['elastic']['install_type']          = "tarball"
#default['elastic']['checksum']              = "8ba8a7c1e32e02056d054638e144290c396b9c0656806a4249ac83fcd28b3c84f89eccf437200ffa435e3edb9f362d20c0a296d70d5a6fa583fd61f21047b16b"
default['elastic']['url']                   = node['download_url'] + "/opensearch/opensearch-#{node['elastic']['opensearch']['version']}-linux-x64.tar.gz"
default['elastic']['user']                  = node['install']['user'].empty? ? "elastic" : node['install']['user']
default['elastic']['user_id']               = '1501'
default['elastic']['elk-user']              = node['install']['user'].empty? ? "elkadmin" : node['install']['user']
default['elastic']['elk-user_id']           = '1502'
default['elastic']['group']                 = node['install']['user'].empty? ? "elastic" : node['install']['user']
default['elastic']['group_id']              = '1501'
default['elastic']['elk-group']             = node['install']['user'].empty? ? "elkadmin" : node['install']['user']
default['elastic']['elk-group_id']          = '1502'
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

default['elastic']['data_volume']['backup_dir'] = "#{node['elastic']['data_volume']['root_dir']}/elasticsearch-backup"
default['elastic']['data_volume']['log_dir']  = "#{node['elastic']['data_volume']['root_dir']}/logs"

default['elastic']['dir']                   = node['install']['dir'].empty? ? "/usr/local" : node['install']['dir']
default['elastic']['home']                  = "#{node['elastic']['dir']}/opensearch-#{node['elastic']['opensearch']['version']}"
default['elastic']['base_dir']              = "#{node['elastic']['dir']}/opensearch"
default['elastic']['data_dir']              = "#{node['elastic']['dir']}/opensearch-data"
default['elastic']['config_dir']            = "#{node['elastic']['base_dir']}/config"
default['elastic']['log_dir']               = "#{node['elastic']['base_dir']}/logs"
default['elastic']['bin_dir']               = "#{node['elastic']['base_dir']}/bin"
default['elastic']['plugins_dir']           = "#{node['elastic']['base_dir']}/plugins"

default['elastic']['pid_file']              = "#{node['elastic']['base_dir']}/opensearch.pid"

default['elastic']['limits']['nofile']      = "65536"
default['elastic']['limits_nproc']          = '65536'
default['elastic']['limits']['memory_limit'] = 'infinity'

default['elastic']['systemd']               = "true"

default['elastic']['memory']['Xms']         = "1024m"
default['elastic']['memory']['Xmx']         = "1024m"
default['elastic']['cluster']['max_shards_per_node'] = "3000"

default['elastic']['thread_stack_size']     = "512k"


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

#Opensearch Security Plugin
default['elastic']['opensearch_security']['enabled']                                = "true"
#default['elastic']['opensearch_security']['url']                                    = "#{node['download_url']}/opensearch_security-#{node['elastic']['opensearch']['version']}.zip"
default['elastic']['opensearch_security']['base_dir']                               = "#{node['elastic']['plugins_dir']}/opensearch-security"
default['elastic']['opensearch_security']['config_dir']                             = "#{node['elastic']['opensearch_security']['base_dir']}/securityconfig"
default['elastic']['opensearch_security']['tools_dir']                              = "#{node['elastic']['opensearch_security']['base_dir']}/tools"
default['elastic']['opensearch_security']['tools']['hash']                          = "#{node['elastic']['opensearch_security']['tools_dir']}/hash.sh"
default['elastic']['opensearch_security']['tools']['securityadmin']                 = "#{node['elastic']['opensearch_security']['tools_dir']}/securityadmin.sh"

default['elastic']['opensearch_security']['admin']['username']                      = "admin"
default['elastic']['opensearch_security']['admin']['password']                      = "adminpw"
default['elastic']['opensearch_security']['kibana']['username']                     = "kibanaserver"
default['elastic']['opensearch_security']['kibana']['password']                     = "kibanaserver"
default['elastic']['opensearch_security']['logstash']['username']                   = "logstash"
default['elastic']['opensearch_security']['logstash']['password']                   = "logstash"
default['elastic']['opensearch_security']['elastic_exporter']['username']           = "elastic_exporter"
default['elastic']['opensearch_security']['elastic_exporter']['password']           = "elastic_exporter"
default['elastic']['opensearch_security']['epipe']['username']                      = "epipeuser"
default['elastic']['opensearch_security']['epipe']['password']                      = "epipepassword"
default['elastic']['opensearch_security']['service_log_viewer']['username']         = "service_log_viewer"
default['elastic']['opensearch_security']['service_log_viewer']['password']         = "service_log_viewer"

default['elastic']['opensearch_security']['keystore']['type']                       = "JKS"
default['elastic']['opensearch_security']['keystore']['file']                       = "kstore.jks"
default['elastic']['opensearch_security']['keystore']['location']                   = "#{node['elastic']['config_dir']}/#{node['elastic']['opensearch_security']['keystore']['file']}"
default['elastic']['opensearch_security']['keystore']['password']                   = node['hopsworks']['master']['password']

default['elastic']['opensearch_security']['truststore']['type']                     = "JKS"
default['elastic']['opensearch_security']['truststore']['file']                     = "tstore.jks"
default['elastic']['opensearch_security']['truststore']['location']                 = "#{node['elastic']['config_dir']}/#{node['elastic']['opensearch_security']['truststore']['file']}"
default['elastic']['opensearch_security']['truststore']['password']                 = node['hopsworks']['master']['password']

default['elastic']['opensearch_security']['https']['enabled']                       = "true"
default['elastic']['opensearch_security']['kibana']['multitenancy']['enabled']      = "true"
default['elastic']['opensearch_security']['kibana']['index']                        = ".kibana"

default['elastic']['opensearch_security']['jwt']['enabled']                         = "true"
default['elastic']['opensearch_security']['jwt']['url_parameter']                   = "jt"
default['elastic']['opensearch_security']['jwt']['roles_key']                       = "roles"
default['elastic']['opensearch_security']['jwt']['subject_key']                     = "sub"
default['elastic']['opensearch_security']['jwt']['exp_ms']                          = "1800000"

default['elastic']['opensearch_security']['roles']['data_owner']['role_name']       = 'data_owner'
default['elastic']['opensearch_security']['roles']['data_scientist']['role_name']   = 'data_scientist'

default['elastic']['opensearch_security']['audit']['enable_rest']                   = "true"
default['elastic']['opensearch_security']['audit']['enable_transport']              = "false"
default['elastic']['opensearch_security']['audit']['type']                          = "internal_elasticsearch"
default['elastic']['opensearch_security']['audit']['threadpool']['size']            = 10
default['elastic']['opensearch_security']['audit']['threadpool']['max_queue_len']   = 100000


default['elastic']['epipe']['search_index']                                         = "projects"
default['elastic']['epipe']['app_provenance_index']                                 = "app_provenance"
default['elastic']['epipe']['file_provenance_index_pattern']                        = "*__file_prov"
default['elastic']['epipe']['featurestore_index']                                   = "featurestore"
