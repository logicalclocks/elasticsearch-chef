action :install_security do
  bash "install_opendistro_security_plugin" do
    user node['elastic']['user']
    code <<-EOF
    #{node['elastic']['bin_dir']}/elasticsearch-plugin install --batch #{node['elastic']['opendistro_security']['url']}
    chmod +x #{node['elastic']['opendistro_security']['tools_dir']}/*
    EOF
  end

  link node['elastic']['opendistro_security']['keystore']['location'] do
    owner node['elastic']['user']
    group node['elastic']['group']
    to node['elastic']['kagent']['keystore']['location']
  end

  link node['elastic']['opendistro_security']['truststore']['location'] do
    owner node['elastic']['user']
    group node['elastic']['group']
    to node['elastic']['kagent']['truststore']['location']
  end

  kagent_keys "generate elastic admin certificate" do
    hopsworks_alt_url new_resource.hopsworks_alt_url
    action :generate_elastic_admin_certificate
  end
end
