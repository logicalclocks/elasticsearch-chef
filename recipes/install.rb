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
  dir node[:elastic][:dir]
  owner node[:elastic][:user]
  group node[:elastic][:group]
  version node[:elastic][:version]
  tarball_url node[:elastic][:url]
  tarball_checksum "86a0c20eea6ef55b14345bff5adf896e6332437b19180c4582a346394abde019"
# node['elasticsearch']['checksums']["#{node[:elastic][:version]}"]['tar'] 
  action :install 
end

mysql_tgz = File.basename(node[:elastic][:mysql_connector_url])
mysql_base = File.basename(node[:elastic][:mysql_connector_url], "-dist.zip") 

path_mysql_tgz = "/tmp/#{mysql_tgz}"

remote_file path_mysql_tgz do
  user node[:elastic][:user]
  group node[:elastic][:group]
  source node[:elastic][:mysql_connector_url]
  mode 0755
  action :create_if_missing
end


Chef::Log.info "Downloading #{mysql_base}"
Chef::Log.info "Unzipgping #{mysql_tgz}"

bash "unpack_mysql_river" do
  user node[:elastic][:user]
  group node[:elastic][:group]
    code <<-EOF
   set -e
   cd /tmp
   unzip  #{path_mysql_tgz} 
   touch #{node[:elastic][:home_dir]}/.#{mysql_base}_downloaded
EOF
  not_if { ::File.exists?( "#{node[:elastic][:home_dir]}/.#{mysql_base}_downloaded")}
end

bash "locate_mysql_river" do
  user "root"
    code <<-EOF
   set -e
   mv /tmp/#{mysql_base} /usr/local
   chown -R #{node[:elastic][:user]} /usr/local/#{mysql_base}
   touch #{node[:elastic][:home_dir]}/.#{mysql_base}_moved
EOF
  not_if { ::File.exists?( "#{node[:elastic][:home_dir]}/.#{mysql_base}_moved")}
end


user_ulimit node[:elastic][:user] do
  filehandle_limit 65535
end
