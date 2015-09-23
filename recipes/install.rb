node.default['java']['jdk_version'] = 7
include_recipe "java"

node.override[:elastcsearch][:url] = node[:elastic][:url]
node.override[:elastcsearch][:version] = node[:elastic][:version]


elasticsearch_user 'elasticsearch' do
  username node[:elastic][:user]
  groupname node[:elastic][:group]
  homedir node[:elastic][:home_dir]
  shell '/bin/bash'
  comment 'Elasticsearch User'
  action :create
end

elasticsearch_install 'elastic_installation' do
  type :tarball
  dir '/usr/local' 
  owner node[:elastic][:user]
  group node[:elastic][:group]
  version node[:elastic][:version]
  tarball_url node[:elastic][:url]
  tarball_checksum "86a0c20eea6ef55b14345bff5adf896e6332437b19180c4582a346394abde019"
# node['elasticsearch']['checksums']["#{node[:elastic][:version]}"]['tar'] 
  action :install 
end

