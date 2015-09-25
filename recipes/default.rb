
node.override[:elastcsearch][:url] = node[:elastic][:url]
node.override[:elastcsearch][:version] = node[:elastic][:version]

my_ip = my_private_ip()

elastic_ip = private_recipe_ip("elastic","default")

# elasticsearch_configure 'my_elasticsearch' do
#   user node[:elastic][:user]
#   group node[:elastic][:group]
#   dir node[:elastic][:home_dir]
#   path_conf node[:elastic][:home_dir] + "/etc/elasticsearch"
#   path_data node[:elastic][:home_dir] + "/var/data/elasticsearch"
#   path_logs node[:elastic][:home_dir] + "/var/log/elasticsearch"
#   logging({:"action" => 'INFO'})
#   allocated_memory '123m'
#   thread_stack_size '512k'
#   env_options '-DFOO=BAR'
#   gc_settings <<-CONFIG
#                 -XX:+UseParNewGC
#                 -XX:+UseConcMarkSweepGC
#                 -XX:CMSInitiatingOccupancyFraction=75
#                 -XX:+UseCMSInitiatingOccupancyOnly
#                 -XX:+HeapDumpOnOutOfMemoryError
#                 -XX:+PrintGCDetails
#               CONFIG
#   configuration ({
#     'cluster.name' => node[:elastic][:cluster_name],
#     'node.name' => node[:elastic][:node_name],
#     'network.host' =>  my_ip,
#     'http.cors.enabled' => true,
#     'http.cors.allow-origin' => "*"
#   })
#   action :manage
# end

elasticsearch_configure 'elasticsearch' do
end

elasticsearch_service 'elasticsearch-hopsworks' do
  user node[:elastic][:user]
  group node[:elastic][:group]
  node_name node[:elastic][:node_name]
  path_conf node[:elastic][:home_dir] + "/etc/elasticsearch"
  path_data node[:elastic][:home_dir] + "/var/data/elasticsearch"
  path_logs node[:elastic][:home_dir] + "/var/log/elasticsearch"
end



#elasticsearch_plugin 'jprante/elasticsearch-jdbc' do

elasticsearch_plugin '/usr/local/elasticsearch-jdbc' do
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



elastic_start "start_install_elastic" do
elastic_ip elastic_ip
end
