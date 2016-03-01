name             'elastic'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      'Installs/Configures/Runs elasticsearch'
version          "0.1.0"

recipe            "elastic::install", "Experiment setup for elasticsearch"
recipe            "elastic::default",  "Configures and starts an elasticsearch server"


depends "kagent"
depends "java"
depends "elasticsearch"
depends "ulimit"
depends "ndb"

%w{ ubuntu debian rhel centos }.each do |os|
  supports os
end

attribute "java/jdk_version",
          :display_name =>  "Jdk version",
          :type => 'string'

attribute "elastic/rivers_enabled",
          :description =>  "Install the JDBC rivers for HopsWorks on this machine",
          :type => 'string'

attribute "elastic/port",
          :description =>  "Port for elasticsearch service (default: 9200)",
          :type => 'string'

attribute "elastic/ulimit_files",
          :description =>  "Number of files to set ulimit to.",
          :type => 'string'

attribute "elastic/ulimit_memlock",
          :description =>  "Memlock size for ulimit",
          :type => 'string'

attribute "elastic/dir",
          :description =>  "Base directory to install elastic search into.",
          :type => 'string'

attribute "elastic/memory",
          :description =>  "Amount of memory for Elasticsearch.",
          :type => 'string'
