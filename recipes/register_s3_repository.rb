private_ip=my_private_ip()
should_run = private_ip.eql?(node['elastic']['default']['private_ips'].sort[0])

elastic_http "Register S3 snapshot repository #{node['elastic']['snapshot']['bucket_name']}" do
    action :put
    only_if { should_run }
    retries 20
    retry_delay 10
    url "#{my_elastic_url()}/_snapshot/s3_repository"
    if opensearch_security?()
        user node['elastic']['opensearch_security']['admin']['username']
        password node['elastic']['opensearch_security']['admin']['password']
    end
    message "{
      \"type\": \"s3\",
      \"settings\":{
        \"bucket\": \"#{node['elastic']['snapshot']['bucket_name']}\",
        \"base_path\": \"opensearch_snapshots\"
      }
    }"
end