repository_name = ""

case node['elastic']['snapshot']['type'].downcase
when "s3"
    repository_name = "s3_repository"
end

private_ip=my_private_ip()
should_run = private_ip.eql?(node['elastic']['default']['private_ips'].sort[0])

bash "Restore snapshot #{repository_name}/#{node['elastic']['snapshot']['restore']['id']}" do
    user node['elastic']['elk-user']
    group node['elastic']['group']
    code <<-EOH
        set -e
        #{node['elastic']['base_dir']}/bin/restore_snapshot.sh -r #{repository_name} -n #{node['elastic']['snapshot']['restore']['id']}
    EOH
    only_if { should_run }
    not_if { node['elastic']['snapshot']['restore']['id'].empty? }
    not_if { repository_name.empty? }
end