action :run do

  kagent_config "elasticsearch" do
    action :systemd_reload
  end
    
  Chef::Log.info  "Elastic Ip is: #{new_resource.elastic_url}, User: #{new_resource.user}"
  
  elastic_http 'poll elasticsearch' do
    action :get
    url "#{new_resource.elastic_url}/"
    user new_resource.user
    password new_resource.password
  end

  elastic_http 'delete projects index' do
    action :delete 
    url "#{new_resource.elastic_url}/projects"
    user new_resource.user
    password new_resource.password
    only_if_cond node['elastic']['projects']['reindex'] == "true"
    only_if_exists true
  end
  elastic_http 'elastic-create-projects-template' do
    action :put
    url "#{new_resource.elastic_url}/_template/#{node['elastic']['epipe']['search_index']}"
    user new_resource.user
    password new_resource.password
    message "{
      \"index_patterns\":[ \"#{node['elastic']['epipe']['search_index']}\" ],
      \"mappings\":{
        \"dynamic\":\"strict\",
        \"properties\":{
           \"doc_type\"     :{\"type\":\"keyword\"},
           \"project_id\"   :{\"type\":\"integer\"},
           \"dataset_id\"   :{\"type\":\"long\"},
           \"public_ds\"    :{\"type\":\"boolean\"},
           \"description\"  :{\"type\":\"text\"},
           \"name\"         :{\"type\":\"text\"},
           \"parent_id\"     :{\"type\":\"long\"},
           \"partition_id\" :{\"type\":\"long\"},
           \"user\"         :{\"type\":\"keyword\"},
           \"group\"        :{\"type\":\"keyword\"},
           \"operation\"    :{\"type\":\"short\"},
           \"size\"         :{\"type\":\"long\"},
           \"timestamp\"    :{\"type\":\"long\"},
           \"xattr\"        :{\"type\":\"nested\",\"dynamic\":true}
        }
      }
    }"
  end
  elastic_http 'elastic-create-projects-index' do
    action :put
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['search_index']}"
    user new_resource.user
    password new_resource.password
    only_if_exists false
    message ''
  end

  elastic_http 'elastic-create-logs-template' do
    action :put 
    url "#{new_resource.elastic_url}/_template/logs"
    user new_resource.user
    password new_resource.password
    message '
    {
       "index_patterns":[
          "*_logs-*"
       ],
       "mappings":{
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
             "class":{
                "type":"keyword"
             },
             "file":{
                "type":"keyword"
             },
             "jobid":{
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
             "logdate":{
                "type":"date"
             }
          }
       }
    }'
  end

  elastic_http 'elastic-create-experiments-template' do
    action :put
    url "#{new_resource.elastic_url}/_template/experiments"
    user new_resource.user
    password new_resource.password
    message '
    {
       "index_patterns":[
          "*_experiments"
       ],
       "mappings":{
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
    }'
  end

  elastic_http 'elastic-create-services-template' do
    action :put 
    url "#{new_resource.elastic_url}/_template/services"
    user new_resource.user
    password new_resource.password
    message '
    {
       "index_patterns":[
          ".services-*"
       ],
       "mappings":{
          "properties":{
             "service":{
                "type":"keyword"
             },
             "host":{
                "type":"keyword"
             },
             "priority":{
                "type":"keyword"
             },
             "logger_name":{
                "type":"text"
             },
             "log_message":{
                "type":"text"
             },
             "logdate":{
                "type":"date"
             }
          }
       }
    }'
  end

  elastic_http 'add_elastic_index_for_kibana' do
    action :put
    url "#{new_resource.elastic_url}/#{node['elastic']['default_kibana_index']}"
    user new_resource.user
    password new_resource.password
    message '{}'
    only_if_exists false
  end

  elastic_http 'elastic-install-file-prov-template' do
    action :put
    url "#{new_resource.elastic_url}/_template/file_prov"
    user new_resource.user
    password new_resource.password
    message '
    {
      "index_patterns": ["*__file_prov"],
      "mappings":{
        "properties":{
          "inode_id":{
            "type":"long"
          },
          "inode_operation":{
            "type":"keyword"
          },
          "inode_name":{
            "type":"text"
          },
          "user_id":{
            "type":"integer"
          },
          "app_id":{
            "type":"keyword"
          },
          "logical_time":{
            "type":"integer"
          },
          "create_timestamp":{
            "type":"long"
          },
          "timestamp":{
            "type":"long"
          },
          "project_i_id":{
            "type":"long"
          },
          "dataset_i_id":{
            "type":"long"
          },
          "parent_i_id":{
            "type":"long"
          },
          "partition_id":{
            "type":"long"
          },
          "entry_type":{
            "type":"keyword"
          },
          "ml_type":{
            "type":"keyword"
          },
          "ml_id":{
            "type":"keyword"
          },
          "r_create_timestamp":{
            "type":"text"
          },
          "r_timestamp":{
            "type":"text"
          },
          "project_name":{
            "type":"text"
          }
        }
      }
    }'
  end

  elastic_http 'elastic-create-app-provenance-template' do
    action :put
    url "#{new_resource.elastic_url}/_template/#{node['elastic']['epipe']['app_provenance_index']}"
    user new_resource.user
    password new_resource.password
    message "{
      \"index_patterns\":[ \"#{node['elastic']['epipe']['app_provenance_index']}\" ],
      \"mappings\":{
        \"properties\":{
          \"app_id\"    :{\"type\":\"keyword\"},
          \"app_state\" :{\"type\":\"keyword\"},
          \"timestamp\" :{\"type\":\"long\"},
          \"app_name\"  :{\"type\":\"text\"},
          \"app_user\"  :{\"type\":\"text\"}
        }
      }
    }"
  end
  elastic_http 'elastic-create-app-provenance-index' do
    action :put
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['app_provenance_index']}"
    user new_resource.user
    password new_resource.password
    only_if_exists false
    message ''
  end
  
  elastic_http 'delete featurestore index' do
    action :delete 
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['featurestore_index']}"
    user new_resource.user
    password new_resource.password
    only_if_cond node['elastic']['featurestore']['reindex'] == "true"
    only_if_exists true
  end

  elastic_http 'elastic-create-featurestore-template' do
    action :put
    url "#{new_resource.elastic_url}/_template/#{node['elastic']['epipe']['featurestore_index']}"
    user new_resource.user
    password new_resource.password
    message "{
      \"index_patterns\":[ \"#{node['elastic']['epipe']['featurestore_index']}\" ],
      \"mappings\":{
        \"dynamic\":\"strict\",
        \"properties\":{
          \"doc_type\"    :{\"type\":\"keyword\"},
          \"name\"        :{\"type\":\"text\"},
          \"version\"     :{\"type\":\"integer\"},
          \"project_id\"  :{\"type\":\"integer\"},
          \"project_name\":{\"type\":\"text\"},
          \"dataset_iid\" :{\"type\":\"long\"},
          \"xattr\"       :{\"type\":\"nested\",\"dynamic\":true}
        }
      }
    }"
  end
  elastic_http 'elastic-create-featurestore-index' do
    action :put
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['featurestore_index']}"
    user new_resource.user
    password new_resource.password
    only_if_exists false
    message ''
  end

  elastic_http 'elastic-create-pypi-template' do
    action :put
    url "#{new_resource.elastic_url}/_template/pypi_libraries"
    user new_resource.user
    password new_resource.password
    message '
    {
       "index_patterns":[
          "pypi_libraries_*"
       ],
      "mappings":{
        "properties":{
          "library":{
            "type":"text"
          }
        }
      }
    }'
  end
end
