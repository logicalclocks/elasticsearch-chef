node.default['java']['jdk_version'] = 7
include_recipe "java"

#node.override[:elasticsearch][:url] = node[:elastic][:url]
node.override[:elasticsearch][:version] = node[:elastic][:version]


case node[:platform_family]
when 'rhel'
  package 'unzip' 
end


elasticsearch_user 'elasticsearch' do
  username node[:elastic][:user]
  groupname node[:elastic][:group]
  shell '/bin/bash'
  comment 'Elasticsearch User'
  instance_name node[:elastic][:node_name]
  action :create
end

install_dir = Hash.new
install_dir['package'] = node[:elastic][:dir]

elasticsearch_install 'elastic_installation' do
  type :tarball
  version node[:elastic][:version]
  instance_name node[:elastic][:node_name]
#  download_url node['elasticsearch']['download_urls_v2']['tar']
  download_url node['elasticsearch']['download_urls']['tar']
#  download_checksum node['elasticsearch']['checksums']["#{node[:elasticsearch][:version]}"]['tar']
  download_checksum node.elastic.checksum
  action :install 
end

mysql_tgz = File.basename(node[:elastic][:mysql_connector_url])
mysql_base = File.basename(node[:elastic][:mysql_connector_url], "-dist.zip") 

path_mysql_tgz = "/tmp/#{mysql_tgz}"

remote_file path_mysql_tgz do
  user node[:elastic][:user]
  group node[:elastic][:group]
  source node[:elastic][:mysql_connector_url]
  mode 0755
  action :create_if_missing
end


Chef::Log.info "Downloading #{mysql_base}"
Chef::Log.info "Unzipgping #{mysql_tgz}"

bash "unpack_mysql_river" do
  user node[:elastic][:user]
  group node[:elastic][:group]
    code <<-EOF
   set -e
   cd /tmp
   unzip  #{path_mysql_tgz} 
   touch #{node[:elastic][:home_dir]}/.#{mysql_base}_downloaded
EOF
  not_if { ::File.exists?( "#{node[:elastic][:home_dir]}/.#{mysql_base}_downloaded")}
end

bash "locate_mysql_river" do
  user "root"
    code <<-EOF
   set -e
   mv -f /tmp/#{mysql_base} #{node[:elastic][:dir]}
   chown -R #{node[:elastic][:user]} #{node[:elastic][:dir]}/#{mysql_base}
   touch #{node[:elastic][:home_dir]}/.#{mysql_base}_moved
   chown #{node[:elastic][:user]} #{node[:elastic][:home_dir]}/.#{mysql_base}_moved
EOF
  not_if { ::File.exists?( "#{node[:elastic][:home_dir]}/.#{mysql_base}_moved")}
end


user_ulimit node[:elastic][:user] do
  filehandle_limit 65535
end

node.override[:elasticsearch][:url] = node[:elastic][:url]
node.override[:elasticsearch][:version] = node[:elastic][:version]


case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.elastic.systemd = "false"
 end
end


my_ip = my_private_ip()
riverdir="#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}"
mysql_ip = my_ip
elastic_ip = private_recipe_ip("elastic","default")

elasticsearch_configure 'my_elasticsearch' do
#  user node[:elastic][:user]
#  group node[:elastic][:group]
#  path_home node[:elastic][:home_dir]
#  path_conf node[:elastic][:home_dir] + "/etc/elasticsearch"
#  path_data node[:elastic][:home_dir] + "/var/data/elasticsearch"
#  path_logs node[:elastic][:home_dir] + "/var/log/elasticsearch"
  # path_pid ({
  #    'tarball' => node[:elastic][:home_dir] + "/var"
  # })
  # path_bin ({
  #    'tarball' => node[:elastic][:home_dir] + "/bin"
  # })
  logging({:"action" => 'INFO'})
  allocated_memory node.elastic.memory
  thread_stack_size node.elastic.thread_stack_size
  env_options '-DFOO=BAR'
  gc_settings <<-CONFIG
#                 -XX:+UseParNewGC
                -XX:+UseConcMarkSweepGC
                -XX:CMSInitiatingOccupancyFraction=75
                -XX:+UseCMSInitiatingOccupancyOnly
                -XX:+HeapDumpOnOutOfMemoryError
                -XX:+PrintGCDetails
              CONFIG
#  nofile_limit 64000
  configuration ({
    'cluster.name' => node[:elastic][:cluster_name],
    'node.name' => node[:elastic][:node_name],
    'network.host' =>  my_ip,
    'http.cors.enabled' => true,
    'http.cors.allow-origin' => "*"
  })
  instance_name node[:elastic][:node_name]
  action :manage
end

elasticsearch_service "elasticsearch-#{node[:elastic][:node_name]}" do
   instance_name node[:elastic][:node_name]
#  user node[:elastic][:user]
#  group node[:elastic][:group]
#  node_name node[:elastic][:node_name]
#  pid_path node[:elastic][:home_dir] + "/var/run"
#  path_conf node[:elastic][:home_dir] + "/etc/elasticsearch"
end

#elasticsearch_plugin "#{node[:elastic][:dir]}/elasticsearch-jdbc" do
#   action :install
#   url "http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/#{node[:elastic][:jdbc_river][:version]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}-dist.zip"
#   instance_name node[:elastic][:node_name]
# end


bash "install_jdbc_river" do
  user "root"
    code <<-EOF
   set -e
   cd /tmp
   rm -f elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}-dist.zip
   wget http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/#{node[:elastic][:jdbc_river][:version]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}-dist.zip
   unzip -fo elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}-dist.zip -d #{node.elastic.dir}
   touch #{riverdir}/.jdbc_river_installed
   chown -R #{node.elastic.user}:#{node.elastic.group} #{riverdir}
EOF
  not_if { ::File.exists?( "#{riverdir}/.jdbc_river_installed")}
end




file "#{node[:elastic][:home_dir]}/config/elasticsearch.yml" do 
  user node[:elastic][:user]
  action :delete
end

template "#{node[:elastic][:home_dir]}/config/elasticsearch.yml" do
  source "elasticsearch.yml.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "755"
  variables({
              :my_ip => my_ip
            })
end

template "#{node[:elastic][:home_dir]}/config/elasticsearch.yml" do
  source "elasticsearch.yml.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "755"
  variables({
              :my_ip => my_ip
            })
end

directory "#{riverdir}/rivers" do
  owner node[:elastic][:user]
  mode "755"
  action :create
end

directory "#{riverdir}/logs" do
  owner node[:elastic][:user]
  mode "755"
  action :create
end


for river in node[:elastic][:rivers] do
  template "#{riverdir}/rivers/#{river}.json" do
    source "#{river}.json.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "755"
  variables({
              :install_path => "#{riverdir}",
              :elastic_host => elastic_ip,
              :mysql_endpoint => mysql_ip + ":3306",
              :mysql_user => node[:mysql][:user],
              :mysql_password => node[:mysql][:password]
            })
  end
end 


for script in %w{ start-river.sh stop-river.sh } do
  template "#{riverdir}/bin/#{script}" do
    source "#{script}.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "755"
    variables({
                :install_path => "#{riverdir}"
              })
  end
end


template "#{riverdir}/bin/elastic-start.sh" do
  source "elastic-start.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end

template "#{riverdir}/bin/elastic-stop.sh" do
  source "elastic-stop.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end



template "#{riverdir}/bin/kill-process.sh" do
  source "kill-process.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end

if node[:kagent][:enabled] == "true"

  kagent_config "elasticsearch-#{node[:host]}" do
    service "elasticsearch-#{node[:host]}"
    start_script "#{riverdir}/bin/elastic-start.sh"
    stop_script "#{riverdir}/bin/elastic-stop.sh"
    log_file "#{node[:elastic][:home]}/logs/#{node[:elastic][:cluster_name]}.log"
    pid_file "#{node[:elastic][:home]}/var/run/#{node[:elastic][:node_name]}.pid"
  end

  if node[:elastic][:rivers_enabled] == "true"

    for river in node[:elastic][:rivers] do
      kagent_config "elasticsearch-#{river}" do
        service "elasticsearch-#{river}"
        start_script "#{riverdir}/bin/#{river}-start.sh" 
        stop_script "#{riverdir}/bin/#{river}-stop.sh"
        log_file "#{riverdir}/rivers/#{river}.log"
        pid_file "#{riverdir}/rivers/#{river}.pid"
      end
    end
  end
end



template "#{node[:elastic][:home_dir]}/bin/elasticsearch-stop.sh" do
  source "elasticsearch-stop.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end

template "#{node[:elastic][:home_dir]}/bin/elasticsearch-start.sh" do
  source "elasticsearch-start.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end


file "/etc/init.d/elasticsearch-#{node[:elastic][:node_name]}" do
   not_if { node[:elastic][:systemd] == "true" }
   action :delete
end

template "/etc/init.d/elasticsearch-#{node[:elastic][:node_name]}" do
  not_if { node[:elastic][:systemd] == "true" }
  source "elasticsearch.erb"
  user "root"
  mode "755"
  variables({
      :elastic_ip => elastic_ip,
      :http_port => node[:elastic][:port],
      :nofile_limit => node[:elastic][:ulimit_files],
      :memlock_limit => node[:elastic][:ulimit_memlock],
      :args => ""
  })
    notifies :enable, "service[elasticsearch-#{node[:elastic][:node_name]}]"
    notifies :restart, "service[elasticsearch-#{node[:elastic][:node_name]}]", :immediately
end


elastic_service = "/lib/systemd/system/elasticsearch-#{node[:elastic][:node_name]}.service"
case node[:platform_family]
  when "rhel"
  elastic_service =  "/usr/lib/systemd/system/elasticsearch-#{node[:elastic][:node_name]}.service"
end

  template "#{elastic_service}" do
    only_if { node[:elastic][:systemd] == "true" }
    source "elasticsearch.service.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "751"
    variables({
                :start_script => "#{node[:elastic][:home_dir]}/bin/elasticsearch-start.sh",
                :stop_script => "#{node[:elastic][:home_dir]}/bin/elasticsearch-stop.sh",
                :pid => "/tmp/elasticsearch.pid"
              })
    notifies :enable, "service[elasticsearch-#{node[:elastic][:node_name]}]"
    notifies :restart, "service[elasticsearch-#{node[:elastic][:node_name]}]", :immediately
  end


service "elasticsearch-#{node[:elastic][:node_name]}" do
  case node[:elastic][:systemd]
    when "true"
    provider Chef::Provider::Service::Systemd
    else
    provider Chef::Provider::Service::Init::Debian
  end
  supports :restart => true, :stop => true, :start => true, :status => true
  action [:enable]
end



for river in node[:elastic][:rivers] do
  template "#{riverdir}/bin/#{river}-start.sh" do
    source "river-start.sh.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "751"
    variables({
        :river => river
    })
  end
  template "#{riverdir}/bin/#{river}-stop.sh" do
    source "river-stop.sh.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "751"
    variables({
        :river => river
    })
  end


  service "#{river}" do
    case node[:elastic][:systemd]
    when "true"
      provider Chef::Provider::Service::Systemd
    else
      provider Chef::Provider::Service::Init::Debian
    end
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  
  service_name = "/lib/systemd/system/#{river}.service"
  case node[:platform_family]
    when "rhel"
    service_name =  "/usr/lib/systemd/system/#{river}.service"
  end

  template "#{service_name}" do
    only_if { node[:elastic][:systemd] == "true" }
    source "river.service.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "751"
    variables({
                :river => river,
                :start_script => "#{riverdir}/bin/#{river}-start.sh",
                :stop_script => "#{riverdir}/bin/#{river}-stop.sh",
                :pid => "#{riverdir}/rivers/#{river}.json.pid"
              })
    notifies :enable, "service[#{river}]"
 #   notifies :restart, "service[#{river}]", :immediately
  end

  template "/etc/init.d/#{river}" do
    not_if { node[:elastic][:systemd] == "true" }
    source "river.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "751"
    variables({
                :river => river,
                :start_script => "#{riverdir}/bin/#{river}-start.sh",
                :stop_script => "#{riverdir}/bin/#{river}-stop.sh",
                :pid_file => "#{riverdir}/rivers/#{river}.json.pid"
              })
    notifies :enable, "service[#{river}]"
#    notifies :restart, "service[#{river}]", :immediately
  end


end

systemd = false
if node.elastic.systemd == "true" || node.elastic.systemd == true 
  systemd = true
end

 elastic_start "start_install_elastic" do
   elastic_ip elastic_ip
   systemd systemd
   action :run
 end
