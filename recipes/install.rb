# Set Kernel parameters
sysctl_param 'vm.max_map_count' do
  value node['elastic']['kernel']['vm.max_map_count']
end

group node['elastic']['group'] do
  action :create
  not_if "getent group #{node['elastic']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

group node['elastic']['elk-group'] do
  action :create
  not_if "getent group #{node['elastic']['elk-group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

user node['elastic']['elk-user'] do
  home node['elastic']['elk-home']
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