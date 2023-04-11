Chef::Log.info "Installing OpenSearch S3 repository"
basename = File.basename(node['elastic']['snapshot']['s3']['plugin_url'])
cached_file = "#{Chef::Config['file_cache_path']}/#{basename}"
remote_file cached_file do
    user node['elastic']['user']
    group node['elastic']['group']
    source node['elastic']['snapshot']['s3']['plugin_url']
    mode 0500
    action :create
end

elastic_start "install plugin" do
    elastic_url my_elastic_url()
    if opensearch_security?()
      user node['elastic']['opensearch_security']['admin']['username']
      password node['elastic']['opensearch_security']['admin']['password']
    end
    service_name "opensearch"
    plugin_path cached_file
    action :install_plugin
    not_if { ::File.exists?("#{node['elastic']['plugins_dir']}/repository-s3") }
end

bash 'setup-s3-repository-access-keys' do
    user node['elastic']['user']
    group node['elastic']['group']
    code <<-EOH
        echo "#{node['elastic']['snapshot']['s3']['access_key_id']}" | #{node['elastic']['bin_dir']}/opensearch-keystore add --force --stdin s3.client.default.access_key
        echo "#{node['elastic']['snapshot']['s3']['secret_access_key']}" | #{node['elastic']['bin_dir']}/opensearch-keystore add --force --stdin s3.client.default.secret_key
    EOH
    not_if { node['elastic']['snapshot']['s3']['access_key_id'].empty? }
end

bash 'setup-s3-repository-session-token' do
    user node['elastic']['user']
    group node['elastic']['group']
    code <<-EOH
        echo "#{node['elastic']['snapshot']['s3']['session_token']}" | #{node['elastic']['bin_dir']}/opensearch-keystore add --force --stdin s3.client.default.session_token
    EOH
    not_if { node['elastic']['snapshot']['s3']['session_token'].empty? }
end

Chef::Log.info "Registering OpenSearch S3 repository"
include_recipe "elastic::register_s3_repository"