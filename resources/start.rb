actions :run

attribute :elastic_url, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => false, :default => nil
attribute :password, :kind_of => String, :required => false, :default => nil

default_action :run
