name             "elastic"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      'Installs/Configures/Runs elasticsearch'
version          "0.6.0"

recipe            "elastic::install", "Experiment setup for elasticsearch"
recipe            "elastic::default",  "Configures and starts an elasticsearch server"
recipe            "elastic::purge",  "Deletes an elasticsearch server"

depends "kagent"
depends "java"
depends "elasticsearch"
depends "ulimit2"
depends "sysctl"

%w{ ubuntu debian rhel centos }.each do |os|
  supports os
end

attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
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

attribute "elastic/user",
          :description =>  "User to install elastic as.",
          :type => 'string'

attribute "elastic/group",
          :description =>  "Group to install elastic as.",
          :type => 'string'

attribute "elastic/dir",
          :description =>  "Base directory to install elastic search into.",
          :type => 'string'

attribute "elastic/memory",
          :description =>  "Amount of memory for Elasticsearch.",
          :type => 'string'

attribute "elastic/memory/Xms",
          :description =>  "Amount of minimum heap memory for Elasticsearch.",
          :type => 'string'

attribute "elastic/memory/Xmx",
          :description =>  "Amount of maximum heap memory for Elasticsearch.",
          :type => 'string'

attribute "elastic/version",
          :description =>  "Elasticsearch version, .e.g, '6.2.4'",
          :type => 'string'

attribute "elastic/checksum",
          :description =>  "Sha-512 checksum for the elasticsearch .tar.gz file",
          :type => 'string'

attribute "elastic/default/private_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "elastic/default/public_ips",
          :description => "Set ip addresses",
          :type => "array"

attribute "install/dir",
          :description => "Set to a base directory under which we will install.",
          :type => "string"

attribute "install/user",
          :description => "User to install the services as",
          :type => "string"
