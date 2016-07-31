action :run do

bash "install_delete_plugin" do
     user "root"
     cwd node.elastic.home_dir
       code <<-EOF
      set -e
      bin/plugin install delete-by-query
   EOF
   not_if { ::File.exists?("#{node.elastic.home_dir}/plugins/delete-by-query/delete-by-query-#{node.elastic.version}.jar") }       
end
   
if new_resource.systemd == true
  bash 'elastic-start-systemd' do
     user "root"
    code <<-EOF
    systemctl daemon-reload
    systemctl stop elasticsearch-#{node.elastic.node_name}
    systemctl start elasticsearch-#{node.elastic.node_name}
  EOF
  end

else
  bash 'elastic-start-systemv' do
     user "root"
    code <<-EOF
    service elasticsearch-#{node.elastic.node_name} stop
    rm /tmp/elasticsearch.pid
    sleep 2
    service elasticsearch-#{node.elastic.node_name} start
  EOF
  end

end

numRetries=10
retryDelay=20


Chef::Log.info  "Elastic Ip is: http://#{new_resource.elastic_ip}:9200"

indexes_installed = "#{node.elastic.home_dir}/.indexes_installed"

 http_request 'elastic-install-indexes' do
   url "http://#{new_resource.elastic_ip}:9200/projects"
   message '
   {
      "mappings": {
         "proj": {},
         "ds": {
            "_parent": {
               "type": "proj"
            }
         },
         "inode": {
            "_parent": {
               "type": "ds"
            }
         }
      }
   }'
   action :put
   retries numRetries
   retry_delay retryDelay
   not_if { ::File.exists?( indexes_installed ) }       
 end

  bash 'elastic-indexes-installed' do
     user node.elastic.user
    code <<-EOF
        touch #{indexes_installed}
  EOF
  end

 
#  new_resource.updated_by_last_action(false)
end
