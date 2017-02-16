include_attribute "elasticsearch"

default.elastic.version               = "5.2.1"
default.elastic.install_type          = "tarball"
default.elastic.checksum              = "f28bfecbb8896bbcf8c6063a474a2ddee29a262c216f56ff6d524fc898094475"
default.elastic.url                   = node.download_url + "/elasticsearch-#{node.elastic.version}.tar.gz"
default.elastic.user                  = "elastic"
default.elastic.group                 = "elastic"

default.elastic.port                  = "9200"

default.elastic.cluster_name          = "hops"
default.elastic.node_name             = "hopsworks"

default.elastic.dir                   = "/usr/local"
default.elastic.version_dir           = "#{node.elastic.dir}/elasticsearch-#{node.elastic.version}"
default.elastic.home_dir              = "#{node.elastic.dir}/elasticsearch"
default.elastic.plugins_dir           = node.elastic.home_dir + "/plugins"

default.elastic.limits.nofile         = "65535"
default.elastic.limits.memory_limit   = "100000"
default.elastic.limits_nproc          = '65536'

default.elastic.systemd               = "true"

default.elastic.memory                = "50m"
default.elastic.thread_stack_size     = "512k"


default.elastic.pid_file              = "/tmp/elasticsearch.pid"


