action :run do

package "curl" do
  action :install
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

numRetries=25
retryDelay=2


Chef::Log.info  "Elastic Ip is: http://#{new_resource.elastic_ip}:9200"

# http_request 'curl_request_project' do
#   url "http://#{new_resource.elastic_ip}:9200/project/child/_mapping"
#   message '{ "child":{ "_parent": {"type": "parent"} } }'
#   action :post
#   retries numRetries
#   retry_delay retryDelay
# end

# http_request 'curl_request_dataset' do
#   url "http://#{new_resource.elastic_ip}:9200/dataset/child/_mapping"
#   message '{ "child":{ "_parent": {"type": "parent"} } }'
#   action :post
#   retries numRetries
#   retry_delay retryDelay
# end


bash 'elastic-install-indexes' do
    user node.elastic.user
    ignore_failure true
    code <<-EOF
 curl -XPOST "http://#{new_resource.elastic_ip}:9200/project" -d '{ "mappings" : { "site" : {},  "proj":{ "_parent": {"type": "site"} } } }'
 curl -XPOST "http://#{new_resource.elastic_ip}:9200/dataset" -d '{ "mappings" : { "ds" : {}, "inode":{ "_parent": {"type": "ds"} } } }'

# curl -XPOST "http://#{new_resource.elastic_ip}:9200/project" -d '{ "mappings" : { "proj" : {  "dynamic": "strict"},  "inode":{"dynamic": "true"}, "_parent": {"type": "site"} } } }'
# curl -XPOST "http://#{new_resource.elastic_ip}:9200/dataset" -d '{ "mappings" : { "ds" : {"dynamic": "strict" }, "inode":{ "dynamic": "strict", "_parent": {"type": "ds"} } } }'


# curl -XPOST "#{new_resource.elastic_ip}:9200/project/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'
# To inform elastic that the parent data type in the dataset index accepts a 'child' data type as a child:
#curl -XPOST "#{new_resource.elastic_ip}:9200/dataset/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'
EOF
end

#  new_resource.updated_by_last_action(false)
end
