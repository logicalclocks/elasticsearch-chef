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
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['search_index']}"
    user new_resource.user
    password new_resource.password
    only_if_cond node['elastic']['projects']['reindex'] == "true"
    only_if_exists true
  end
  projects_index_mappings = '
  {
     "mappings":{
        "dynamic":"strict",
        "properties":{
           "doc_type":{
              "type":"keyword"
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
  }'

  elastic_http 'elastic-install-projects-index' do
    action :put
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['search_index']}"
    user new_resource.user
    password new_resource.password
    only_if_exists false
    message projects_index_mappings
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

  #Beam job server and sdkworker templates
  elastic_http 'elastic-create-beamjobserver-template' do
    action :put 
    url "#{new_resource.elastic_url}/_template/beamjobserver"
    user new_resource.user
    password new_resource.password
    message '
    {
       "index_patterns":[
          "*_beamjobserver-*"
       ],
       "mappings":{
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
    }'
  end

  elastic_http 'elastic-create-beamsdkworker-template' do
    action :put 
    url "#{new_resource.elastic_url}/_template/beamsdkworker"
    user new_resource.user
    password new_resource.password
    message '
    {
       "index_patterns":[
          "*_beamsdkworker-*"
       ],
       "mappings":{
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

  elastic_http 'elastic-install-app-provenance-index' do
    action :put
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['app_provenance_index']}"
    user new_resource.user
    password new_resource.password
    message '
    {
      "mappings":{
        "properties":{
          "app_id":{
            "type":"keyword"
          },
          "app_state":{
            "type":"keyword"
          },
          "timestamp":{
            "type":"long"
          },
          "app_name":{
            "type":"text"
          },
          "app_user":{
            "type":"text"
          }
        }
      }
    }'
    only_if_exists false
  end
  
  elastic_http 'delete featurestore index' do
    action :delete 
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['featurestore_index']}"
    user new_resource.user
    password new_resource.password
    only_if_cond node['elastic']['featurestore']['reindex'] == "true"
    only_if_exists true
  end

  featurestore_index_mappings = '
  {
    "mappings":{
      "dynamic":"strict",
      "properties":{
        "doc_type":{
          "type":"keyword"
        },
        "name":{
          "type":"text"
        },
        "version":{
          "type":"integer"
        },
        "project_id":{
          "type":"integer"
        },
        "project_name":{
          "type":"text"
        },
        "dataset_iid":{
          "type":"long"
        },
        "xattr":{
          "type":"nested",
          "dynamic":true
        }
      }
    }
  }'

  elastic_http 'elastic-install-featurestore-index' do
    action :put
    url "#{new_resource.elastic_url}/#{node['elastic']['epipe']['featurestore_index']}"
    user new_resource.user
    password new_resource.password
    only_if_exists false
    message featurestore_index_mappings
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
  
  elk_crypto_dir = x509_helper.get_crypto_dir(node['elastic']['elk-user'])
  template node['elastic']['epipe']['reindex-base-indices_script'] do
      source "reindex-base-indices.sh.erb"
      owner "root"
      group "root"
      mode 0750
      variables({
         :elkUserCert => "#{elk_crypto_dir}/#{x509_helper.get_certificate_bundle_name(node['elastic']['elk-user'])}",
         :elkUserKey => "#{elk_crypto_dir}/#{x509_helper.get_private_key_pkcs8_name(node['elastic']['elk-user'])}",
         :projectsMappings => projects_index_mappings,
         :fsMappings => featurestore_index_mappings
      })
  end

end
