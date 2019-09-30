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

# Poll elasticsearch to make sure it's alive before progressing
http_request 'delete projects index' do
  action :get
  url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/"
  retries numRetries
  retry_delay retryDelay
end

# Delete projects index if reindex is set to true
http_request 'delete projects index' do
  action :delete
  url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/projects"
  retries numRetries
  retry_delay retryDelay
  only_if { node['elastic']['projects']['reindex'] == "true" }
  not_if "test \"$(curl -s -o /dev/null -w '%{http_code}\n' http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/projects)\" = \"404\""
end


http_request 'elastic-install-projects-index' do
   url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/projects"
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
                    "type":"long"
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
                    "type":"long"
                },
                "partition_id":{
                    "type":"long"
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
   only_if "test \"$(curl -s -o /dev/null -w '%{http_code}\n' http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/projects)\" = \"404\""
 end

 http_request 'elastic-create-logs-template' do
   url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/_template/logs"
   headers 'Content-Type' => 'application/json'
   message '
   {
     "index_patterns": ["*_logs-*"],
     "mappings":{
       "doc":{
         "properties":{
           "application" : {
             "type" : "keyword"
           },
           "host" : {
             "type" : "keyword"
           },
           "jobname" : {
             "type" : "keyword"
           },
           "class" : {
             "type" : "keyword"
           },
           "file" : {
             "type" : "keyword"
           },
           "jobid" : {
             "type" : "keyword"
           },
           "logger_name" : {
             "type" : "keyword"
           },
           "project" : {
             "type" : "keyword"
           },
           "log_message" : {
             "type" : "text"
           },
           "priority" : {
             "type" : "text"
           },
           "logdate" : {
             "type" : "date"
           }
         }
       }
     }
   }'
   action :put
   retries numRetries
   retry_delay retryDelay
 end

 http_request 'elastic-create-experiments-template' do
   url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/_template/experiments"
   headers 'Content-Type' => 'application/json'
   message '
   {
     "template":"*_experiments",
     "mappings":{
       "experiments":{
         "properties":{
           "project":{
             "type":"keyword"
           },
           "user":{
             "type":"keyword"
           },
           "name":{
             "type":"keyword"
           },
           "module":{
             "type":"keyword"
           },
           "function":{
             "type":"keyword"
           },
           "metric":{
             "type":"keyword"
           },
           "hyperparameter":{
             "type":"keyword"
           },
           "status":{
           "type":"keyword"
           },
           "start":{
           "type":"date"
           },
           "finished":{
           "type":"date"
           },
           "executors":{
             "type":"keyword"
           },
           "memory_per_executor":{
             "type":"keyword"
           },
           "gpus_per_executor":{
             "type":"keyword"
           },
           "spark":{
             "type":"keyword"
           },
           "tensorflow":{
             "type":"keyword"
           },
           "kafka":{
             "type":"keyword"
           },
           "cuda":{
             "type":"keyword"
           },
           "hops_py":{
             "type":"keyword"
           },
           "hops":{
             "type":"keyword"
           },
           "hopsworks":{
             "type":"keyword"
           },
           "logdir":{
             "type":"keyword"
           },
           "hyperparameter_space":{
             "type":"keyword"
           },
           "versioned_resources":{
             "type":"keyword"
           },
           "description":{
             "type":"keyword"
           },
           "app_id":{
             "type":"keyword"
           }
         }
       }
     }
   }'
   action :put
   retries numRetries
   retry_delay retryDelay
 end

  http_request 'elastic-create-kagent-template' do
   url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/_template/kagent"
   headers 'Content-Type' => 'application/json'
   message '
   {
     "index_patterns": ["*_kagent-*"],
     "mappings":{
       "doc":{
         "properties":{
           "project_name" : {
             "type" : "keyword"
           },
           "operation" : {
             "type" : "keyword"
           },
           "artifact" : {
             "type" : "keyword"
           },
           "artifact_version" : {
             "type" : "keyword"
           },
           "return_code" : {
             "type" : "integer"
           },
           "return_message" : {
             "type" : "text"
           }
         }
       }
     }
   }'
   action :put
   retries numRetries
   retry_delay retryDelay
  end

#Beam job server and sdkworker templates
http_request 'elastic-create-beamjobserver-template' do
   url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/_template/beamjobserver"
   headers 'Content-Type' => 'application/json'
   message '
   {
   "index_patterns":[
      "*_beamjobserver-*"
   ],
   "mappings":{
      "doc":{
         "properties":{
            "host":{
               "type":"keyword"
            },
            "jobname":{
               "type":"keyword"
            },
            "thread":{
               "type":"keyword"
            },
            "file":{
               "type":"keyword"
            },
            "logger_name":{
               "type":"keyword"
            },
            "project":{
               "type":"keyword"
            },
            "log_message":{
               "type":"text"
            },
            "priority":{
               "type":"text"
            },
            "jobport":{
               "type":"text"
            }
         }
      }
   }
}'
   action :put
   retries numRetries
   retry_delay retryDelay
  end

http_request 'elastic-create-beamsdkworker-template' do
   url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/_template/beamsdkworker"
   headers 'Content-Type' => 'application/json'
   message '
   {
     "index_patterns": ["*_beamsdkworker-*"],
     "mappings":{
       "doc":{
         "properties":{
           "host":{
               "type":"keyword"
            },
            "file":{
               "type":"keyword"
            },
            "project":{
               "type":"keyword"
            },
	    "timestamp":{
               "type":"date"
            },
	    "appid":{
               "type":"keyword"
            },
            "log_message":{
               "type":"text"
            }
         }
       }
     }
   }'
   action :put
   retries numRetries
   retry_delay retryDelay
  end


  
 http_request 'add_elastic_index_for_kibana' do
   action :put
   headers 'Content-Type' => 'application/json'
   message '{}'
   url "http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/#{node['elastic']['default_kibana_index']}"
   retries numRetries
   retry_delay retryDelay
   only_if "test \"$(curl -s -o /dev/null -w '%{http_code}\n' http://#{new_resource.elastic_ip}:#{node['elastic']['port']}/#{node['elastic']['default_kibana_index']})\" = \"404\""
 end
end
