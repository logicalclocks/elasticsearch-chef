action :run do

package "curl" do 
end


# Run the scripts

bash 'elastic-scripts' do
    user node[:elastic][:user]
    code <<-EOF
   nohup #{node[:elastic][:home_dir]}/bin/elasticsearch > /tmp/elasticsearch.log &
   echo $! > /tmp/elasticsearch.pid
EOF
end

bash 'elastic-index-creation' do
    user node[:elastic][:user]
    code <<-EOF
    /usr/local/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/parent.sh
    /usr/local/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/dataset.sh
    /usr/local/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/child_pr.sh
    /usr/local/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}/bin/child_ds.sh 
EOF
end


bash 'elastic-install-indexes' do
    user node[:elastic][:user]
    code <<-EOF
curl -XPOST "#{new_resource.elastic_ip}:9200/project/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'

# To inform elastic that the parent data type in the dataset index accepts a 'child' data type as a child:

curl -XPOST "#{new_resource.elastic_ip}:9200/dataset/child/_mapping" -d '{ "child":{ "_parent": {"type": "parent"} } }'

EOF
end





#  new_resource.updated_by_last_action(false)
end
