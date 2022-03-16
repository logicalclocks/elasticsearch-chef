action :run do

  bash 'Move elasticsearch data to data volume' do
    user 'root'
    code <<-EOH
    mv -f #{node['elastic']['data_dir']}/* #{node['elastic']['data_volume']['data_dir']}
    mv -f #{node['elastic']['data_dir']} #{node['elastic']['data_dir']}_deprecated
  EOH
    only_if { conda_helpers.is_upgrade }
    only_if { ::File.directory?(node['elastic']['data_dir'])}
    not_if { ::File.symlink?(node['elastic']['data_dir'])}
  end


  bash 'Move elasticsearch logs to data volume' do
    user 'root'
    code <<-EOH
    mv -f #{node['elastic']['log_dir']}/* #{node['elastic']['data_volume']['log_dir']}
    mv -f #{node['elastic']['log_dir']} #{node['elastic']['log_dir']}_deprecated
  EOH
    only_if { conda_helpers.is_upgrade }
    only_if { ::File.directory?(node['elastic']['log_dir'])}
    not_if { ::File.symlink?(node['elastic']['log_dir'])}
  end
end


action :secureadmin do

  bash 'Run secureadmin.sh on opensearch' do
    user 'root'
    code <<-EOH
    #{node['elastic']['opensearch_security']['tools_dir']}/run_securityAdmin.sh
     # cd #{node['elastic']['opensearch_security']['config_dir']}
#      ../tools/securityadmin.sh -icl -nhnv -ts #{node['elastic']['opensearch_security']['truststore']['location']} -ks #{node['elastic']['opensearch_security']['keystore']['location']} -kspass #{node['elastic']['opensearch_security']['keystore']['password']} -tspass #{node['elastic']['opensearch_security']['truststore']['password']} -h #{new_resource.elastic_host}
  EOH
  end
  
end  
