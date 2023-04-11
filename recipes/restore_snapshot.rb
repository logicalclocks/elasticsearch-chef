repository_name = ""

case node['elastic']['snapshot']['type'].downcase
when "s3"
    repository_name = "s3_repository"
end

private_ip=my_private_ip()
should_run = private_ip.eql?(node['elastic']['default']['private_ips'].sort[0])

elastic_http "Restoring snapshot #{node['elastic']['snapshot']['restore']['id']} from #{node['elastic']['snapshot']['type']}" do
    action :post
    url "#{my_elastic_url()}/_snapshot/#{repository_name}/#{node['elastic']['snapshot']['restore']['id']}/_restore?wait_for_completion=true"
    if opensearch_security?()
        user node['elastic']['opensearch_security']['admin']['username']
        password node['elastic']['opensearch_security']['admin']['password']
    end
    message ''
    only_if { should_run }
    not_if { node['elastic']['snapshot']['restore']['id'].empty? }
    not_if { repository_name.empty? }
end