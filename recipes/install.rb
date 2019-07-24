# Set Kernel parameters
sysctl_param 'vm.max_map_count' do
  value node['elastic']['kernel']['vm.max_map_count']
end

# Download exporter 
base_package_filename = File.basename(node['elastic']['exporter']['url'])
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

remote_file cached_package_filename do
  source node['elastic']['exporter']['url']
  owner "root"
  mode "0644"
  action :create_if_missing
end

directory node['elastic']['dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  mode '0750'
  action :create
  not_if { ::Dir.exists?(node['elastic']['dir']) }
end

elastic_exporter_downloaded= "#{node['elastic']['exporter']['home']}/.elastic_exporter.extracted_#{node['elastic']['exporter']['version']}"
# Extract elastic_exporter 
bash 'extract_elastic_exporter' do
  user "root"
  code <<-EOH
    tar -xf #{cached_package_filename} -C #{node['elastic']['dir']}
    chown -R #{node['elastic']['user']}:#{node['elastic']['group']} #{node['elastic']['exporter']['home']}
    chmod -R 750 #{node['elastic']['home']}
    touch #{elastic_exporter_downloaded}
    chown #{node['elastic']['user']} #{elastic_exporter_downloaded}
  EOH
  not_if { ::File.exists?( elastic_exporter_downloaded ) }
end

link node['elastic']['exporter']['base_dir'] do
  owner node['elastic']['user']
  group node['elastic']['group']
  to node['elastic']['exporter']['home']
end
