name             'elastic'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      'Installs/Configures/Runs elasticsearch'
version          "0.1"

recipe            "elastic::install", "Experiment setup for elasticsearch"
recipe            "elastic::default",  "Configures and starts an elasticsearch server"


depends "kagent"
depends 'apt'
depends 'yum'
depends 'chef-sugar'
depends "java"
depends "elasticsearch"
depends "ulimit"

%w{ ubuntu debian rhel centos }.each do |os|
  supports os
end


attribute "elastic/rivers_enabled",
          :description =>  "Install the JDBC rivers for HopsWorks on this machine",
          :type => 'string'
