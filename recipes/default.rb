
node.override[:elastcsearch][:url] = node[:elastic][:url]
node.override[:elastcsearch][:version] = node[:elastic][:version]

my_ip = my_private_ip()

elasticsearch_configure 'my_elasticsearch' do
  dir '/usr/local/elasticsearch'
  user node[:elastic][:user]
  group node[:elastic][:group]
  logging({:"action" => 'INFO'})
  allocated_memory '123m'
  thread_stack_size '512k'
  env_options '-DFOO=BAR'
  gc_settings <<-CONFIG
                -XX:+UseParNewGC
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

elasticsearch_plugin 'jprante/elasticsearch-jdbc' do
  user node[:elastic][:user]
  group node[:elastic][:group]
  action :install
#  url "http://xbib.org/repository/org/xbib/elasticsearch/plugin/elasticsearch-river-jdbc/#{node[:elastic][:jdbc_river][:version]}/elasticsearch-river-jdbc-#{node[:elastic][:jdbc_river][:version]}-plugin.zip"
  url "https://github.com/jprante/elasticsearch-jdbc/archive/#{node[:elastic][:jdbc_river][:version]}.tar.gz" 
end

mysql_tgz = File.basename(node[:elastic][:mysql_connector_url])
mysql_base = File.basename(node[:elastic][:mysql_connector_url], ".tar.gz") 

#path_mysql_tgz = "#{Chef::Config[:file_cache_path]}/#{mysql_tgz}"
path_mysql_tgz = "/tmp/#{mysql_tgz}"

remote_file path_mysql_tgz do
  user node[:elastic][:user]
  group node[:elastic][:group]
  source node[:elastic][:mysql_connector_url]
  mode 0755
  action :create_if_missing
end


bash "unpack_mysql_connector" do
  user node[:elastic][:user]
  group node[:elastic][:group]
    code <<-EOF
   cd /tmp
   tar -xzf #{path_mysql_tgz} 
   # copy mysql-connector jar file to plugins/jdbc
   mkdir -p #{node[:elastic][:home_dir]}/plugins/jdbc
   cp #{mysql_base}/#{mysql_base}-bin.jar #{node[:elastic][:home_dir]}/plugins/jdbc/
   touch #{node[:elastic][:home_dir]}/.#{mysql_base}_downloaded
EOF
  not_if { ::File.exists?( "#{node[:elastic][:home_dir]}/.#{mysql_base}_downloaded")}
end


file "#{node[:elastic][:home_dir]}/conf/elasticsearch.yml" do 
  user node[:elastic][:user]
  action :delete
end

template "#{node[:elastic][:home_dir]}/conf/elasticsearch.yml" do
  source "elasticsearch.yml.erb"
  user node[:elastic][:user]
  group node[:elastic][:group]
  mode "755"
  variables({
              :my_ip => my_ip
            })
end


elasticsearch_service 'elasticsearch-hopsworks' do
  node_name node[:elastic][:node_name]
  path_conf '/usr/local/elasticsearch/etc/elasticsearch'
  pid_path '/usr/local/elasticsearch/var/run'
  user node[:elastic][:user]
  group node[:elastic][:group]
end

