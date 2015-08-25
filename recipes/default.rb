#private_ip = my_private_ip()
#public_ip = my_public_ip()

script 'run_experiment' do
  cwd "/home/elasticsearch-chef"
   user node['elasticsearch-chef']['user']
  group node['elasticsearch-chef']['group']
  interpreter "bash"
  code <<-EOM

  EOM
end

