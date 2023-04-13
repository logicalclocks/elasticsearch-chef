if node['elastic']['snapshot']['type'].casecmp?("s3")
    include_recipe "elastic::install_s3_repository"
end