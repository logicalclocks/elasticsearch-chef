
case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.elastic.systemd = "false"
 end
end

if node.elastic.systemd == "false"

  bash 'kill_running_elastic_service' do
    user "root"
    ignore_failure true
    code <<-EOF
      service elasticsearch-#{node.elastic.node_name} stop
      pkill elasticsearch-#{node.elastic.node_name}
      rm /etc/init.d/elasticsearch-#{node.elastic.node_name}
    EOF
  end


else # systemd

  bash 'kill_running_elastic_service' do
    user "root"
    ignore_failure true
    code <<-EOF
      systemctl stop elasticsearch-#{node.elastic.node_name}
      pkill elasticsearch-#{node.elastic.node_name}
      rm -f /usr/lib/systemd/system/elasticsearch-#{node.elastic.node_name}
      rm -f /lib/systemd/system/elasticsearch-#{node.elastic.node_name}
    EOF
  end

end

# elasticsearch_install 'my_es_installation' do
#   type :tarball
#   dir "#{node.elastic.dir}"
#   owner node.elastic.user
#   group node.elastic.group
#   tarball_url node.elastic.url
#   ignore_failure true
#   action :remove
# end

directory node.elastic.version_dir do
  recursive true
  action :delete
  ignore_failure true
end

link node.elastic.home_dir do
  action :delete
  ignore_failure true
end
