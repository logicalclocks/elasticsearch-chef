action :run do

bash "install_delete_plugin" do
     user "root"
     cwd node['elastic']['home_dir']
       code <<-EOF
      set -e
      bin/plugin install delete-by-query
   EOF
   not_if { ::File.exists?("#{node['elastic']['home_dir']}/plugins/delete-by-query/delete-by-query-#{node['elastic']['version']}.jar") }       
end
   
if new_resource.systemd == true
  bash 'elastic-start-systemd' do
     user "root"
    code <<-EOF
    systemctl daemon-reload
    systemctl stop elasticsearch
    systemctl start elasticsearch
  EOF
  end

else
  bash 'elastic-start-systemv' do
     user "root"
    code <<-EOF
    service elasticsearch stop
    rm /tmp/elasticsearch.pid
    sleep 2
    service elasticsearch start
  EOF
  end

end

numRetries=10
retryDelay=20


Chef::Log.info  "Elastic Ip is: http://#{new_resource.elastic_ip}:9200"

indexes_installed = "#{node['elastic']['home_dir']}/.indexes_installed"

 http_request 'elastic-install-indexes' do
   url "http://#{new_resource.elastic_ip}:9200/projects"
   message '
   {  
    "mappings":{  
        "proj":{  
            "dynamic":"strict",
            "properties":{  
                "description":{  
                    "type":"string"
                },
                "name":{  
                    "type":"string"
                },
                "parent_id":{  
                    "type":"long"
                },
                "user":{  
                    "type":"string"
                }
            }
        },
        "ds":{  
            "dynamic":"strict",
            "_parent":{  
                "type":"proj"
            },
            "_routing":{  
                "required":true
            },
            "properties":{  
                "description":{  
                    "type":"string"
                },
                "name":{  
                    "type":"string"
                },
                "parent_id":{  
                    "type":"long"
                },
                "project_id":{  
                    "type":"long"
                },
                "public_ds":{  
                    "type":"boolean"
                },
                "xattr":{  
                    "type":"nested",
                    "dynamic":true
                }
            }
        },
        "inode":{  
            "dynamic":"strict",
            "_parent":{  
                "type":"ds"
            },
            "_routing":{  
                "required":true
            },
            "properties":{  
                "dataset_id":{  
                    "type":"long"
                },
                "group":{  
                    "type":"string"
                },
                "name":{  
                    "type":"string"
                },
                "operation":{  
                    "type":"long"
                },
                "parent_id":{  
                    "type":"long"
                },
                "project_id":{  
                    "type":"long"
                },
                "size":{  
                    "type":"long"
                },
                "timestamp":{  
                    "type":"long"
                },
                "user":{  
                    "type":"string"
                },
                "xattr":{  
                    "type":"nested",
                    "dynamic":true
                }
            }
        }
      }
   }'
   action :put
   retries numRetries
   retry_delay retryDelay
   not_if { ::File.exists?( indexes_installed ) }       
 end

  bash 'elastic-indexes-installed' do
     user node['elastic']['user']
    code <<-EOF
        chmod 750 #{node['elastic']['version_dir']}
        touch #{indexes_installed}
  EOF
  end

 
#  new_resource.updated_by_last_action(false)
end
