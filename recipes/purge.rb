
node[:elastic][:rivers].each { |d| 

  bash 'kill_running_service_#{d}' do
    user "root"
    ignore_failure :true
    code <<-EOF
      service stop #{d}
#      pkill ??
    EOF
  end

  file "/etc/init.d/#{d}" do
    action :delete
    ignore_failure :true
  end
}


elasticsearch_install 'my_es_installation' do
  type :tarball
  dir "#{node[:elastic][:dir]}"
  owner node[:elastic][:user]
  group node[:elastic][:group]
  tarball_url node[:elastic][:url]
  ignore_failure :true
  action :remove
end

directory node[:elastic][:version_dir] do
  recursive true
  action :delete
  ignore_failure :true
end

link node[:elastic][:home_dir] do
  action :delete
  ignore_failure :true
end


directory " #{node[:elastic][:dir]}/elasticsearch-jdbc-#{node[:elastic][:jdbc_river][:version]}" do
  recursive true
  action :delete
  ignore_failure :true
end
