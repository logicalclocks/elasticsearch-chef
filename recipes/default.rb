include_recipe "java"

node.override['elasticsearch']['version'] = node['elastic']['version']
node.override['elasticsearch']['download_urls']['tarball'] = node['elastic']['url']

Chef::Log.info "Using systemd (1): #{node['elastic']['systemd']}"

#service_name = "elasticsearch-#{node['elastic']['node_name']}"
service_name = "elasticsearch"
pid_file = "/tmp/elasticsearch.pid"

case node['platform_family']
when 'rhel'
  package 'unzip'
end

group node['elastic']['group'] do
  action :create
  not_if "getent group #{node['elastic']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['elastic']['user'] do
  gid node['elastic']['group']
  shell "/bin/bash"
  manage_home false
  system true
  action :create
  not_if "getent passwd #{node['elastic']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

elasticsearch_user 'elasticsearch' do
  username node['elastic']['user']
  groupname node['elastic']['group']
  shell '/bin/bash'
  comment 'Elasticsearch User'
  instance_name node['elastic']['node_name']
  action :nothing
end

install_dir = Hash.new
install_dir['package'] = node['elastic']['dir']
install_dir['tarball'] = node['elastic']['dir']

node.override['ark']['prefix_root'] = node['elastic']['dir']
node.override['ark']['prefix_bin'] = node['elastic']['dir']
node.override['ark']['prefix_home'] = node['elastic']['dir']

elasticsearch_install 'elasticsearch' do
  type "tarball"
  version node['elastic']['version']
  instance_name node['elastic']['node_name']
  download_url node['elasticsearch']['download_urls']['tarball']
  download_checksum node['elastic']['checksum']
  dir node['elastic']['dir']
  action :install
end

node.override['ulimit']['conf_dir'] = "/etc/security"
node.override['ulimit']['conf_file'] = "limits.conf"

node.override['ulimit']['params']['default']['nofile'] = 65000     # hard and soft open file limit for all users
node.override['ulimit']['params']['default']['nproc'] = 8000

node.override['ulimit']['conf_dir'] = "/etc/security"
node.override['ulimit']['conf_file'] = "limits.conf"

node.override['ulimit']['params']['default']['nofile'] = 65000     # hard and soft open file limit for all users
node.override['ulimit']['params']['default']['nproc'] = 8000

include_recipe "ulimit2"

node.override['elasticsearch']['url'] = node['elastic']['url']
node.override['elasticsearch']['version'] = node['elastic']['version']

my_ip = my_private_ip()
mysql_ip = my_ip
elastic_ip = private_recipe_ip("elastic","default")

elasticsearch_configure 'elasticsearch' do
   path_home node['elastic']['home_dir']
   path_conf "#{node['elastic']['home_dir']}/config"
   path_data "#{node['elastic']['data_dir']}"
   logging({:"action" => 'INFO'})
   configuration ({
     'cluster.name' => node['elastic']['cluster_name'],
     'node.name' => node['elastic']['node_name'],
     'network.host' =>  my_ip,
     'http.cors.enabled' => true,
     'http.cors.allow-origin' => "*"
   })
   instance_name node['elastic']['node_name']
   action :manage
end

elasticsearch_service "#{service_name}" do
   instance_name node['elastic']['node_name']
   init_source 'elasticsearch.erb'
   init_cookbook 'elastic'
   service_actions ['nothing']
end

template "#{node['elastic']['home_dir']}/config/elasticsearch.yml" do
  source "elasticsearch.yml.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "755"
  variables({
              :my_ip => my_ip
            })
end

template "#{node['elastic']['home_dir']}/config/jvm.options" do
  source "jvm.options.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "755"
end

template "#{node['elastic']['home_dir']}/bin/elasticsearch-start.sh" do
  source "elasticsearch-start.sh.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "751"
end

template "#{node['elastic']['home_dir']}/bin/elasticsearch-stop.sh" do
  source "elasticsearch-stop.sh.erb"
  user node['elastic']['user']
  group node['elastic']['group']
  mode "751"
end

template "#{node['elastic']['home_dir']}/bin/kill-process.sh" do
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
    log_file "#{node['elastic']['home_dir']}/logs/#{node['elastic']['cluster_name']}.log"
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
  source "elasticsearch.service.erb"
  user "root"
  group "root"
  mode "754"
  variables({
              :start_script => "#{node['elastic']['home_dir']}/bin/elasticsearch-start.sh",
              :stop_script => "#{node['elastic']['home_dir']}/bin/elasticsearch-stop.sh",
              :install_dir => "#{node['elastic']['home_dir']}",
              :pid => pid_file,
              :nofile_limit => node['elastic']['limits']['nofile'],
              :memlock_limit => node['elastic']['limits']['memory_limit']
            })
#    notifies :enable, "service[#{service_name}]"
#    notifies :restart, "service[#{service_name}]", :immediately
end

Chef::Log.info "Using systemd (2): #{node['elastic']['systemd']}"

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
  elastic_ip elastic_ip
  systemd true
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

template systemd_script do
  source "elastic_exporter.service.erb"
  owner "root"
  group "root"
  mode 0664
  if node['services']['enabled'] == "true"
    notifies :enable, "service[elastic_exporter]", :immediately
  end
  notifies :restart, "service[elastic_exporter]", :immediately
  variables({
    'es_master_uri' => "http://#{elastic_ip}:#{node['elastic']['port']}"
  })
end

kagent_config "elastic_exporter" do
  action :systemd_reload
end

if node['install']['upgrade'] == "true"
  kagent_config "#{service_name}" do
    action :systemd_reload
  end

  kagent_config "elastic_exporter" do
    action :systemd_reload
  end
end
