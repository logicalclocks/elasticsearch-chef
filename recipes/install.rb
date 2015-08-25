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
  tarball_url node[:elastic][:url]
  tarball_checksum node[:elastic][:checksum]
  action :install # could be :remove as well
end

