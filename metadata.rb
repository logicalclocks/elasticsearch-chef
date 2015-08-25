name             'elasticsearch-chef'
maintainer       "elastic"
maintainer_email "jdowling@kth.se"
license          "Apache v2.0"
description      'Installs/Configures/Runs elasticsearch-chef'
version          "0.1"

recipe            "elasticsearch-chef::install", "Experiment setup for elasticsearch-chef"
recipe            "elasticsearch-chef::default",  "configFile=; Experiment name: default"


depends "kagent"



%w{ ubuntu debian rhel centos }.each do |os|
  supports os
end

attribute "elasticsearch-chef/version",
:description => "Version of elasticsearch-chef",
:type => 'string',
:default => "0.1"


attribute "elasticsearch-chef/url",
:description => "Url to download binaries for elasticsearch-chef",
:type => 'string',
:default => ""

attribute "elasticsearch-chef/user",
:description => "Run elasticsearch-chef as this user",
:type => 'string',
:default => "elasticsearch-chef"


