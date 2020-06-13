# Set Kernel parameters
sysctl_param 'vm.max_map_count' do
  value node['elastic']['kernel']['vm.max_map_count']
end

group node['hops']['group'] do
  gid node['hops']['group_id']
  action :create
  not_if "getent group #{node['hops']['group']}"
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end
