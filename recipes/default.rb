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
    'node.name' => 'hopsworks'
  })

  action :manage
end

elasticsearch_plugin 'jprante/elasticsearch-jdbc' do
  plugin_dir '/usr/local/elasticsearch/plugins'
end

elasticsearch_service 'elasticsearch-hopsworks' do
  node_name 'hopsworks'
  path_conf '/usr/local/elasticsearch/etc/elasticsearch'
  pid_path '/usr/local/elasticsearch/var/run'
  user node[:elastic][:user]
  group node[:elastic][:group]
end
