
node.override[:elastcsearch][:url] = node[:elastic][:url]
node.override[:elastcsearch][:version] = node[:elastic][:version]

my_ip = my_private_ip()

mysql_ip = my_ip
elastic_ip = private_recipe_ip("elastic","default")

elasticsearch_configure 'my_elasticsearch' do
  user node[:elastic][:user]
  group node[:elastic][:group]
  dir node[:elastic][:home_dir]
  path_conf node[:elastic][:home_dir] + "/etc/elasticsearch"
  path_data node[:elastic][:home_dir] + "/var/data/elasticsearch"
  path_logs node[:elastic][:home_dir] + "/var/log/elasticsearch"
  logging({:"action" => 'INFO'})
  allocated_memory '123m'
  thread_stack_size '512k'
  env_options '-DFOO=BAR'
  gc_settings <<-CONFIG
#                 -XX:+UseParNewGC
                -XX:+UseConcMarkSweepGC
                -XX:CMSInitiatingOccupancyFraction=75
                -XX:+UseCMSInitiatingOccupancyOnly
                -XX:+HeapDumpOnOutOfMemoryError
                -XX:+PrintGCDetails
              CONFIG
  configuration ({
    'cluster.name' => node[:elastic][:cluster_name],
    'node.name' => node[:elastic][:node_name],
    'network.host' =>  my_ip,
    'http.cors.enabled' => true,
    'http.cors.allow-origin' => "*"
  })
  action :manage
end

elasticsearch_service "elasticsearch-#{node[:elastic][:node_name]}" do
  user node[:elastic][:user]
  group node[:elastic][:group]
  node_name node[:elastic][:node_name]
  pid_path node[:elastic][:home_dir] + "/var/run"
  path_conf node[:elastic][:home_dir] + "/etc/elasticsearch"
end



elasticsearch_plugin "#{node[:elastic][:dir]}/elasticsearch-jdbc" do
  user node[:elastic][:user]
  group node[:elastic][:group]
  action :install
   url "http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/#{node[:elastic][:jdbc_river][:version]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}-dist.zip"
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

directory "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/rivers" do
  owner node[:elastic][:user]
  mode "755"
  action :create
end

directory "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/log" do
  owner node[:elastic][:user]
  mode "755"
  action :create
end


for river in node[:elastic][:rivers] do
  template "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/rivers/#{river}.json" do
    source "#{river}.json.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "755"
  variables({
              :install_path => "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}",
              :elastic_host => elastic_ip,
              :mysql_endpoint => mysql_ip + ":3306",
              :mysql_user => node[:mysql][:user],
              :mysql_password => node[:mysql][:password]
            })
  end
end 


for script in %w{ start-river.sh stop-river.sh } do
  template "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/#{script}" do
    source "#{script}.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "755"
    variables({
                :install_path => "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}"
              })
  end
end


template "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/elastic-start.sh" do
  source "elastic-start.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end

template "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/elastic-stop.sh" do
  source "elastic-stop.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end


for river in node[:elastic][:rivers] do
  template "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/#{river}-start.sh" do
    source "river-start.sh.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "751"
    variables({
        :river => river
    })
  end
  template "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/#{river}-stop.sh" do
    source "river-stop.sh.erb"
    user node[:elastic][:user]
    group node[:elastic][:group]
    mode "751"
    variables({
        :river => river
    })
  end
end

template "#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/kill-process.sh" do
  source "kill-process.sh.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "751"
end



if node[:kagent][:enabled] == "true"

  riverdir="#{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}"

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


# file "/etc/init.d/elasticsearch-#{node[:elastic][:node_name]}" do
#    action :delete
# end
# template "/etc/init.d/elasticsearch-#{node[:elastic][:node_name]}" do
#   source "elasticsearch.erb"
#   user "root"
#   mode "755"
#   variables({
#       :elastic_ip => elastic_ip,
#       :http_port => node[:elastic][:port],
#       :path_conf => node[:elastic][:home_dir] + "/etc/elasticsearch",
#       :nofile_limit => node[:elastic][:ulimit_files],
#       :memlock_limit => node[:elastic][:ulimit_memlock],
#       :args => ""
#   })
# end

elastic_start "start_install_elastic" do
  elastic_ip elastic_ip
end

service "elasticsearch-#{node[:elastic][:node_name]}" do
  action [:enable]
end
