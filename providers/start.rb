action :run do

package "curl" do
  action :install
end

if new_resource.systemd == true
  bash 'elastic-start-systemd' do
     user "root"
    code <<-EOF
    systemctl stop elasticsearch-#{node.elastic.node_name}
    systemctl start elasticsearch-#{node.elastic.node_name}
  EOF
  end


  # If starting a river fails, it means it is already running, which is ok.
  bash 'elastic-river-start' do
    #  user node.elastic.user
    user "root"
    ignore_failure true
    code <<-EOF
     systemctl stop parent.service
     systemctl stop dataset.service
     systemctl stop child_ds.service
     systemctl stop child_pr.service

     systemctl start parent.service
     systemctl start dataset.service
     systemctl start child_ds.service
     systemctl start child_pr.service
     sleep 2
EOF
  end

else 
  bash 'elastic-start-systemv' do
#    user node.elastic.user
     user "root"
    code <<-EOF
    service elasticsearch-#{node.elastic.node_name} stop
    service elasticsearch-#{node.elastic.node_name} start
  EOF
  end

  # If starting a river fails, it means it is already running, which is ok.
  bash 'elastic-river-start' do
    #  user node.elastic.user
    user "root"
    ignore_failure true
    code <<-EOF
     service parent stop
     service dataset stop
     service child_ds stop
     service child_pr stop

     service parent start
     service dataset start
     service child_ds start
     service child_pr start

    sleep 2
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
 curl -XPOST "#{new_resource.elastic_ip}:9200/project" -d ' "mappings" : { "site" : {},  "proj":{ "_parent": {"type": "site"} } }'
 curl -XPOST "#{new_resource.elastic_ip}:9200/dataset" -d '{ "mappings" : { "ds" : {}, "inode":{ "_parent": {"type": "ds"} } }'


# curl -XPOST "#{new_resource.elastic_ip}:9200/project/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'
# To inform elastic that the parent data type in the dataset index accepts a 'child' data type as a child:
#curl -XPOST "#{new_resource.elastic_ip}:9200/dataset/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'
EOF
end

#  new_resource.updated_by_last_action(false)
end
