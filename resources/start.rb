actions :run

attribute :elastic_ip, :kind_of => String, :required => true
attribute :systemd, :kind_of => [TrueClass, FalseClass], :required => true

default_action :run
