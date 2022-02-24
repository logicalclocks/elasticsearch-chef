node.override['elasticsearch']['version'] = node['elastic']['opensearch']['version']
node.override['elasticsearch']['download_urls']['tarball'] = node['elastic']['url']

service_name = "opensearch"

case node['platform_family']
when 'rhel'
  package 'unzip'
end

# User certs must belong to elastic group to be able to rotate x509 material
group node['elastic']['group'] do
  action :modify
  members node['kagent']['certs_user']
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

# User certs must belong to elk-group group to be able to rotate x509 material
group node['elastic']['elk-group'] do
  action :modify
  members node['kagent']['certs_user']
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

directory node['data']['dir'] do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
  not_if { ::File.directory?(node['data']['dir']) }
end

directory node['elastic']['data_volume']['root_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
end

directory node['elastic']['data_volume']['data_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
end

directory node['elastic']['data_volume']['backup_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
end

bash 'Move elasticsearch data to data volume' do
  user 'root'
  code <<-EOH
    set -e
    mv -f #{node['elastic']['data_dir']}/* #{node['elastic']['data_volume']['data_dir']}
    mv -f #{node['elastic']['data_dir']} #{node['elastic']['data_dir']}_deprecated
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(node['elastic']['data_dir'])}
  not_if { File.symlink?(node['elastic']['data_dir'])}
end

link node['elastic']['data_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
  to node['elastic']['data_volume']['data_dir']
end

link node['elastic']['backup_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
  to node['elastic']['data_volume']['backup_dir']
end

install_dir = Hash.new
install_dir['package'] = node['elastic']['dir']
install_dir['tarball'] = node['elastic']['dir']

package_url = "#{node['elastic']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end

elastic_downloaded = "#{node['elastic']['home']}/.elastic.extracted_#{node['elastic']['version']}"
# Extract elastic
bash 'extract_elastic' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node['elastic']['dir']}
                chown -R #{node['elastic']['user']}:#{node['elastic']['group']} #{node['elastic']['home']}
                chmod 750 #{node['elastic']['home']}
                cd #{node['elastic']['home']}
                touch #{elastic_downloaded}
                chown #{node['elastic']['user']} #{elastic_downloaded}
        EOH
     not_if { ::File.exists?( elastic_downloaded ) }
end

link node['elastic']['base_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  to node['elastic']['home']
end

directory node['elastic']['data_volume']['log_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0750'
end

bash 'Move elasticsearch logs to data volume' do
  user 'root'
  code <<-EOH
    set -e
    mv -f #{node['elastic']['log_dir']}/* #{node['elastic']['data_volume']['log_dir']}
    mv -f #{node['elastic']['log_dir']} #{node['elastic']['log_dir']}_deprecated
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(node['elastic']['log_dir'])}
  not_if { File.symlink?(node['elastic']['log_dir'])}
end

# Logs directory is created by elasticsearch provider
# Small hack to create the symlink below
directory node['elastic']['log_dir'] do
  recursive true
  action :delete
  not_if { conda_helpers.is_upgrade }
end

link node['elastic']['log_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0750'
  to node['elastic']['data_volume']['log_dir']
end

node.override['ulimit']['conf_dir'] = "/etc/security"
node.override['ulimit']['conf_file'] = "limits.conf"

node.override['ulimit']['params']['default']['nofile'] = 65536     # hard and soft open file limit for all users
node.override['ulimit']['params']['default']['nproc'] = 8000

include_recipe "ulimit2"

node.override['elasticsearch']['url'] = node['elastic']['url']
node.override['elasticsearch']['version'] = node['elastic']['version']

all_elastic_hosts = all_elastic_host_names()
all_elastic_admin_dns = get_all_elastic_admin_dns()
elastic_host = my_host()

template "#{node['elastic']['config_dir']}/opensearch.yml" do
  source "opensearch.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "650"
  variables({
              :path_home => node['elastic']['base_dir'],
              :instance_name => elastic_host,
              :node_master => node['elastic']['master'].casecmp?("true") ,
              :node_data => node['elastic']['data'].casecmp?("true"),
              :elastic_host =>  elastic_host,
              :discovery_seed_hosts => all_elastic_hosts,
              :cluster_initial_master_nodes => all_elastic_hosts,
              :opensearch_security_disabled => node['elastic']['opensearch_security']['enabled'].casecmp?("false"),
              :opensearch_security_ssl_http_enabled => node['elastic']['opensearch_security']['https']['enabled'].casecmp?("true"),
              :opensearch_security_nodes_dn => all_elastic_hosts,
              :opensearch_security_authcz_admin_dn => all_elastic_admin_dns,
              :opensearch_security_audit_enable_rest => node['elastic']['opensearch_security']['audit']['enable_rest'].casecmp?("true"),
              :opensearch_security_audit_enable_transport => node['elastic']['opensearch_security']['audit']['enable_transport'].casecmp?("true"),
              :opensearch_security_audit_type => node['elastic']['opensearch_security']['audit']['type'],
              :opensearch_security_audit_threadpool_size => node['elastic']['opensearch_security']['audit']['threadpool']['size'],
              :opensearch_security_audit_threadpool_max_queue_len => node['elastic']['opensearch_security']['audit']['threadpool']['max_queue_len']
              
            })
end


# We must change directory permissions again after elasticsearch_configure
directory node['elastic']['data_volume']['data_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
end

directory node['elastic']['data_volume']['backup_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
end

directory node['elastic']['data_volume']['log_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0700'
end

hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:8181"
if node.attribute? "hopsworks"
  if node["hopsworks"].attribute? "https" and node["hopsworks"]['https'].attribute? ('port')
    hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node['hopsworks']['https']['port']}"
  end
end

elastic_opensearch 'opensearch_security' do
  hopsworks_alt_url hopsworks_alt_url
  action :install_security
end

template "#{node['elastic']['opensearch_security']['config_dir']}/action_groups.yml" do
  source "action_groups.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "650"
end

file node['elastic']['opensearch_security']['tools']['hash'] do
  mode '750'
end

file node['elastic']['opensearch_security']['tools']['securityadmin'] do
  mode '750'
end

template "#{node['elastic']['opensearch_security']['config_dir']}/internal_users.yml" do
  source "internal_users.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "650"
end

template "#{node['elastic']['opensearch_security']['config_dir']}/roles.yml" do
  source "roles.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "650"
end

template "#{node['elastic']['opensearch_security']['config_dir']}/roles_mapping.yml" do
  source "roles_mapping.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "650"
end

template "#{node['elastic']['opensearch_security']['config_dir']}/tenants.yml" do
  source "tenants.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "650"
end

elk_crypto_dir = x509_helper.get_crypto_dir(node['elastic']['elk-user'])
template "#{node['elastic']['opensearch_security']['tools_dir']}/run_securityAdmin.sh" do
  source "run_securityAdmin.sh.erb"
  user node['elastic']['elk-user']
  group node['elastic']['group']
  mode "700"
  variables({
     :hopsCAFile => "#{elk_crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}",
     :elkUserCert => "#{elk_crypto_dir}/#{x509_helper.get_certificate_bundle_name(node['elastic']['elk-user'])}",
     :elkUserKey => "#{elk_crypto_dir}/#{x509_helper.get_private_key_pkcs8_name(node['elastic']['elk-user'])}"
  })
end

signing_key = ""
if node['elastic']['opensearch_security']['jwt']['enabled'].casecmp?("true")
  signing_key = get_elk_signing_key()
end

template "#{node['elastic']['opensearch_security']['config_dir']}/config.yml" do
  source "config.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "650"
  variables({
    :signing_key => signing_key,
  })
end

template "#{node['elastic']['base_dir']}/config/jvm.options" do
  source "jvm.options.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "600"
end

template "#{node['elastic']['base_dir']}/bin/opensearch-start.sh" do
  source "opensearch-start.sh.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "751"
end

template "#{node['elastic']['base_dir']}/bin/opensearch-stop.sh" do
  source "opensearch-stop.sh.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "751"
end

template "#{node['elastic']['base_dir']}/bin/kill-process.sh" do
  source "kill-process.sh.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "751"
end


if node['kagent']['enabled'] == "true"
# Note, the service below cannot have a '-' in its name, so we call it just
# "elasticsearch". The service_name will be the name of the init.d/systemd script.
  kagent_config service_name do
    service "ELK"
    log_file "#{node['elastic']['base_dir']}/logs/#{node['elastic']['cluster_name']}.log"
  end
end

file "/etc/init.d/#{service_name}" do
   action :delete
end

file "/etc/defaults/#{service_name}" do
   action :delete
end

file "/etc/rc.d/init.d/#{service_name}" do
  action :delete
end

elastic_service = "/lib/systemd/system/#{service_name}.service"

case node['platform_family']
when "rhel"
  elastic_service =  "/usr/lib/systemd/system/#{service_name}.service"
end

execute "systemctl daemon-reload"

template "#{elastic_service}" do
  source "#{service_name}.service.erb"
  user "root"
  group "root"
  mode "754"
  variables({
              :start_script => "#{node['elastic']['base_dir']}/bin/opensearch-start.sh",
              :stop_script => "#{node['elastic']['base_dir']}/bin/opensearch-stop.sh",
              :install_dir => "#{node['elastic']['base_dir']}",
              :nofile_limit => node['elastic']['limits']['nofile'],
              :memlock_limit => node['elastic']['limits']['memory_limit']
            })
end

service "#{service_name}" do
  case node['elastic']['systemd']
  when "true"
  provider Chef::Provider::Service::Systemd
  else
  provider Chef::Provider::Service::Init::Debian
  end
  supports :restart => true, :stop => true, :start => true, :status => true
  if node['services']['enabled'] == "true"
    action :enable
  end
end


elastic_start "start_install_elastic" do
  elastic_url my_elastic_url()
  if opensearch_security?()
    user node['elastic']['opensearch_security']['admin']['username']
    password node['elastic']['opensearch_security']['admin']['password']
  end
  service_name service_name
  action :run
end

# Download exporter
base_package_filename = File.basename(node['elastic']['exporter']['url'])
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

remote_file cached_package_filename do
  source node['elastic']['exporter']['url']
  owner "root"
  mode "0644"
  action :create_if_missing
end

elastic_exporter_downloaded= "#{node['elastic']['exporter']['home']}/.elastic_exporter.extracted_#{node['elastic']['exporter']['version']}"
# Extract elastic_exporter
bash 'extract_elastic_exporter' do
  user "root"
  code <<-EOH
    set -e
    tar -xf #{cached_package_filename} -C #{node['elastic']['dir']}
    chown -R #{node['elastic']['user']}:#{node['elastic']['group']} #{node['elastic']['exporter']['home']}
    chmod -R 750 #{node['elastic']['exporter']['home']}
    touch #{elastic_exporter_downloaded}
    chown #{node['elastic']['user']} #{elastic_exporter_downloaded}
  EOH
  not_if { ::File.exists?( elastic_exporter_downloaded ) }
end

link node['elastic']['exporter']['base_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  to node['elastic']['exporter']['home']
end

# Template and configure elasticsearch exporter
case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/elastic_exporter.service"
else
  systemd_script = "/lib/systemd/system/elastic_exporter.service"
end

service "elastic_exporter" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

deps = "#{service_name}.service"

elastic_crypto_dir = x509_helper.get_crypto_dir(node['elastic']['user'])
template systemd_script do
  source "elastic_exporter.service.erb"
  owner "root"
  group "root"
  mode 0664
  variables({
              :deps => deps
            })
  if node['services']['enabled'] == "true"
    notifies :enable, "service[elastic_exporter]", :immediately
  end
  notifies :restart, "service[elastic_exporter]", :immediately
  variables({
     :es_master_uri => get_my_es_master_uri(),
     :hopsCAFile => "#{elastic_crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}",
  })
end

kagent_config "elastic_exporter" do
  action :systemd_reload
end

if node['kagent']['enabled'] == "true"
   kagent_config "elastic_exporter" do
     service "Monitoring"
     restart_agent false
   end
end

if service_discovery_enabled()
  # Register elastic with Consul
  consul_service "Registering Elastic with Consul" do
    service_definition "elastic-consul.hcl.erb"
    action :register
  end
end

if conda_helpers.is_upgrade
  kagent_config "#{service_name}" do
    action :systemd_reload
  end

  kagent_config "elastic_exporter" do
    action :systemd_reload
  end
end
