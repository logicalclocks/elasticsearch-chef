# Set Kernel parameters
sysctl_param 'vm.max_map_count' do
  value node['elastic']['kernel']['vm.max_map_count']
end

directory node['elastic']['dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0750'
  action :create
  not_if { ::Dir.exists?(node['elastic']['dir']) }
end