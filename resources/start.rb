actions :run, :install_plugin

attribute :service_name, :kind_of => String, :required => true
attribute :elastic_url, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => false, :default => nil
attribute :password, :kind_of => String, :required => false, :default => nil
attribute :plugin_path, :kind_of => String, :required => false, :default => nil

default_action :run
