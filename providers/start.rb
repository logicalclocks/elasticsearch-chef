action :run do



bash 'elastic-scripts' do
    user node[:elastic][:user]
    code <<-EOF
   nohup #{node[:elastic][:home_dir]}/bin/elasticsearch > /tmp/elasticsearch.log &
   echo $! > /tmp/elasticsearch.pid
EOF
end

bash 'elastic-init-scripts' do
    user "root"
    code <<-EOF
    # perl -i.bak -p -e 's{ES_INCLUDE=$ES_INCLUDE}{. $ES_INCLUDE &&}g' /etc/init.d/elasticsearch-#{node[:elastic][:node_name]}
    # perl -i -p -e "s/localhost/#{new_resource.elastic_ip}/g" /etc/init.d/elasticsearch-#{node[:elastic][:node_name]}
#     service elasticsearch-#{node[:elastic][:node_name]} start
EOF
end


bash 'elastic-index-creation' do
    user node[:elastic][:user]
    code <<-EOF
    cd #{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}
    ./bin/start-river.sh rivers/parent.json
    ./bin/start-river.sh rivers/dataset.json
    ./bin/start-river.sh rivers/child_pr.json
    ./bin/start-river.sh rivers/child_ds.json
    sleep 2
EOF
end

numRetries=15
retryDelay=2

http_request 'curl_request_project' do
  url "http://#{new_resource.elastic_ip}:9200/project/child/_mapping"
  message '{ "child":{ "_parent": {"type": "parent"} } }'
  action :post
  retries numRetries
  retry_delay retryDelay
end

http_request 'curl_request_dataset' do
  url "http://#{new_resource.elastic_ip}:9200/dataset/child/_mapping"
  message '{ "child":{ "_parent": {"type": "parent"} } }'
  action :post
  retries numRetries
  retry_delay retryDelay
end


bash 'elastic-install-indexes' do
    user node[:elastic][:user]
    code <<-EOF
#curl -XPOST "#{new_resource.elastic_ip}:9200/project/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'
# To inform elastic that the parent data type in the dataset index accepts a 'child' data type as a child:
#curl -XPOST "#{new_resource.elastic_ip}:9200/dataset/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'
EOF
end

#  new_resource.updated_by_last_action(false)
end
