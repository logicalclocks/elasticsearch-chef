action :install_security do
  bash "install_opendistro_security_plugin" do
    user node['elastic']['user']
    group node['elastic']['group']
    code <<-EOF
    #{node['elastic']['bin_dir']}/elasticsearch-plugin install --batch #{node['elastic']['opendistro_security']['url']}
    chmod -R 750 #{node['elastic']['opendistro_security']['base_dir']}
    chmod 770 #{node['elastic']['opendistro_security']['tools_dir']}
    EOF
  end

  hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:8181"
  if node.attribute? "hopsworks"
    if node["hopsworks"].attribute? "https" and node["hopsworks"]['https'].attribute? ('port')
      hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node['hopsworks']['https']['port']}"
    end
  end
  elastic_crypto_dir = x509_helper.get_crypto_dir(node['elastic']['user'])
  kagent_hopsify "Generate x.509" do
    user node['elastic']['user']
    crypto_directory elastic_crypto_dir
    hopsworks_alt_url hopsworks_alt_url
    action :generate_x509
    not_if { node["kagent"]["enabled"] == "false" }
  end


  elk_crypto_dir = x509_helper.get_crypto_dir(node['elastic']['elk-user'])
  kagent_hopsify "Generate x.509" do
    user node['elastic']['elk-user']
    crypto_directory elk_crypto_dir
    hopsworks_alt_url hopsworks_alt_url
    action :generate_x509
    not_if { node["kagent"]["enabled"] == "false" }
  end

  kstore_file, tstore_file = x509_helper.get_user_keystores_name(node['elastic']['user'])
  link node['elastic']['opendistro_security']['keystore']['location'] do
    owner node['elastic']['user']
    group node['elastic']['group']
    to "#{elastic_crypto_dir}/#{kstore_file}"
  end

  link node['elastic']['opendistro_security']['truststore']['location'] do
    owner node['elastic']['user']
    group node['elastic']['group']
    to "#{elastic_crypto_dir}/#{tstore_file}"
  end
end
