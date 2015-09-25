action :run do

package "curl" do 
end

bash 'elastic-setup' do
    user node[:elastic][:user]
    code <<-EOF
curl -XPOST 'localhost:9200/project/child/_mapping' -d '{ "child":{ "_parent": {"type": "parent"} } }'

# To inform elastic that the parent data type in the dataset index accepts a 'child' data type as a child:

curl -XPOST 'localhost:9200/dataset/child/_mapping' -d '{ "child":{ "_parent": {"type": "parent"} } }'

EOF
#    not_if ""
end



# Run the scripts

bash 'elastic-scripts' do
    user node[:elastic][:user]
    code <<-EOF



EOF
end
#  new_resource.updated_by_last_action(false)
end
