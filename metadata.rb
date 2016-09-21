name			       "jetty"
maintainer       "Opscode, Inc."
maintainer_email "devops@tealium.com"
description      "Installs/Configures jetty"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.4.0"

%w{ java jpackage }.each do |cb|
  depends cb
end

%w{ debian ubuntu }.each do |os|
  supports os
end

recipe "jetty::default", "Installs and configures Jetty"
