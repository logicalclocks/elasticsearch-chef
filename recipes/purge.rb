elasticsearch_install 'my_es_installation' do
  type :tarball
  dir '/usr/local' 
  owner node[:elastic][:user]
  group node[:elastic][:group]
  tarball_url node[:elastic][:url]
  action :remove
end
