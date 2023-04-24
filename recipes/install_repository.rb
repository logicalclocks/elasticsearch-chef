if node['elastic']['snapshot']['bucket_name'].empty?
    if node['hops'].attribute?('aws_s3_bucket')
      node.override['elastic']['snapshot']['bucket_name'] = node['hops']['aws_s3_bucket']
    end
end


if node['elastic']['snapshot']['type'].casecmp?("s3")
    if node['elastic']['snapshot']['s3']['access_key_id'].empty?
        if node['hops'].attribute?('aws_access_key_id')
            node.override['elastic']['snapshot']['s3']['access_key_id'] = node['hops']['aws_access_key_id']
        end
    end
    if node['elastic']['snapshot']['s3']['secret_access_key'].empty?
        if node['hops'].attribute?('aws_secret_access_key')
            node.override['elastic']['snapshot']['s3']['secret_access_key'] = node['hops']['aws_secret_access_key']
        end
    end

    include_recipe "elastic::install_s3_repository"
end