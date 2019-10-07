actions :get, :delete, :put, :post, :post_curl

attribute :url, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => false, :default => nil
attribute :password, :kind_of => String, :required => false, :default => nil

attribute :retries, :kind_of => Integer, :required => false, :default => 10
attribute :retryDelay, :kind_of => Integer, :required => false, :default => 20

attribute :only_if_cond, :kind_of => [TrueClass, FalseClass], :required => false, :default => nil
attribute :only_if_exists, :kind_of => [TrueClass, FalseClass], :required => false, :default => nil

attribute :message, :kind_of => String, :required => false, :default => nil
attribute :headers, :kind_of => Hash, :required => false, :default => nil

default_action :get
