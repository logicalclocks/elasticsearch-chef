# Set Kernel parameters
sysctl_param 'vm.max_map_count' do
  value node['elastic']['kernel']['vm.max_map_count']
end

group node['elastic']['group'] do
  gid node['elastic']['group_id']
  action :create
  not_if "getent group #{node['elastic']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['elastic']['elk-group'] do
  gid node['elastic']['elk-group_id']
  action :create
  not_if "getent group #{node['elastic']['elk-group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['elastic']['elk-user'] do
  home node['elastic']['elk-home']
  uid node['elastic']['elk-user_id']
  gid node['elastic']['elk-group']
  shell "/bin/bash"
  manage_home true
  system true
  action :create
  not_if "getent passwd #{node['elastic']['elk-user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['elastic']['group'] do
  action :modify
  members node['elastic']['elk-user']
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node["kagent"]["certs_group"] do
  action :manage
  append true
  excluded_members node['elastic']['user']
  not_if { node['install']['external_users'].casecmp("true") == 0 }
  only_if { conda_helpers.is_upgrade }
end

user node['elastic']['user'] do
  home node['elastic']['user-home']
  uid node['elastic']['user_id'].to_i  
  gid node['elastic']['group']
  gid node['elastic']['group_id']  
  shell "/bin/bash"
  manage_home true
  system true
  action :create
  not_if "getent passwd #{node['elastic']['user']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end


# Disable elasticsearch service to handle upgrades from 2.4 to 2.5
service "elasticsearch" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action [:disable, :stop]
end
