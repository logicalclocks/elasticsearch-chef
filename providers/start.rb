action :run do

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


Chef::Log.info  "Elastic Ip is: http://#{new_resource.elastic_ip}:#{node['elastic']['port']}"

indexes_installed = "#{node['elastic']['home_dir']}/.indexes_installed"

 http_request 'elastic-install-projects-index' do
   url "http://#{new_resource.elastic_ip}:9200/projects"
   headers 'Content-Type' => 'application/json'
   message '
   {
    "mappings":{
        "_doc":{
            "dynamic":"strict",
            "properties":{
               "doc_type":{
                 "type" : "keyword"
               },
               "project_id":{
                  "type":"integer"
                },
                "dataset_id":{
                    "type":"integer"
                },
                "public_ds":{
                    "type":"boolean"
                },
                "description":{
                    "type":"text"
                },
                "name":{
                    "type":"text"
                },
                "parent_id":{
                    "type":"integer"
                },
                "partition_id":{
                  "type" : "integer"
                },
                "user":{
                    "type":"keyword"
                },
                "group":{
                    "type":"keyword"
                },
                "operation":{
                    "type":"short"
                },
                "size":{
                    "type":"long"
                },
                "timestamp":{
                    "type":"long"
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

 http_request 'elastic-create-logs-template' do
   url "http://#{new_resource.elastic_ip}:9200/_template/logs"
   headers 'Content-Type' => 'application/json'
   message '
   {
     "template":"*_logs",
     "mappings":{
       "logs":{
         "properties":{
           "application":{
             "type":"keyword"
           },
           "host":{
             "type":"keyword"
           },
           "jobname":{
             "type":"keyword"
           },
           "file":{
             "type":"keyword"
           },
           "timestamp":{
             "type":"date"
           },
           "project":{
             "type":"keyword"
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

 http_request 'elastic-create-experiments-template' do
   url "http://#{new_resource.elastic_ip}:9200/_template/experiments"
   headers 'Content-Type' => 'application/json'
   message '
   {
     "template":"*_experiments",
     "mappings":{
       "experiments":{
         "properties":{
           "hops-py-library":{
             "type":"keyword"
           },
           "tensorflow":{
             "type":"keyword"
           },
           "spark":{
             "type":"keyword"
           },
           "hopsworks":{
             "type":"keyword"
           },
           "hops":{
             "type":"keyword"
           },
           "kafka":{
             "type":"keyword"
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

 http_request 'add_elastic_index_for_kibana' do
   action :put
   url "http://#{new_resource.elastic_ip}:9200/#{node['elastic']['default_kibana_index']}?pretty"
   retries numRetries
   retry_delay retryDelay
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
