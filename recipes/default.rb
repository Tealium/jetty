#
# Cookbook Name:: jetty
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "java"

opt_dir = "/opt/"

#creating a user to run under Jetty
user node[:jetty][:user] do
  comment "jetty user used to run jetty"
  shell "/bin/false"
end

group node[:jetty][:group] do
  members [ node[:jetty][:group]]
end

#creating the necessary directories that Jetty will need to be installed correctly
[ node[:jetty][:log_dir], node[:jetty][:contexts_dir], node[:jetty][:config_dir], node[:jetty][:lib_dir] ].each do |dir|
    directory dir do
     mode 0775
     owner node[:jetty][:user]
     group node[:jetty][:group]
     recursive true
    action :create
  end
end

#downloading the Jetty .tar file from URL link we specified in the Attribute file
remote_file "#{opt_dir}#{node[:jetty][:jetty_version]}.tar.gz" do
  source node[:jetty][:jetty_url]
  mode 0775
  action :create_if_missing
end

#running a bash script to untar the .tar.gz Jetty file and move directories to appropriate locations
bash "Installing Jetty 8 because Tealium is the bomb" do
  user "root"
  cwd "/opt"
  code <<-BASH_SCRIPT
  tar xfz #{node[:jetty][:jetty_version]}.tar.gz
  cd #{node[:jetty][:jetty_version]}
  mv #{opt_dir}#{node[:jetty][:jetty_version]}/logs #{node[:jetty][:log_dir]}
  mv #{opt_dir}#{node[:jetty][:jetty_version]}/etc #{node[:jetty][:config_dir]}
  mv #{opt_dir}#{node[:jetty][:jetty_version]}/webapps #{node[:jetty][:webapps_dir]}
  mv #{opt_dir}#{node[:jetty][:jetty_version]}/contexts #{node[:jetty][:contexts_dir]}
  BASH_SCRIPT
  not_if do
    File.exists?("/opt/#{node[:jetty][:jetty_version]}")
  end
end

#changing the directory user to jetty 
%w{node[:jetty][:config_dir] node[:jetty][:webapps_dir] node[:jetty][:contexts_dir] opt_dir + node[:jetty][:jetty_version]}.each do |dir|
  directory dir do
    mode 0775
    owner node[:jetty][:user]
    group node[:jetty][:group]
     recursive true
  end

end

#creating symbolic link
#link opt_dir + node[:jetty][:jetty_version] + "/contexts" do
#  to node[:jetty][:context_dir]
#end


#creating symbolic links so all Jetty files point to /opt/Jetty-version
link opt_dir + node[:jetty][:jetty_version] + "/logs"  do
  to node[:jetty][:log_dir]
  owner node[:jetty][:user]
  group node[:jetty][:group]
end

#creating symbolic link
link opt_dir + node[:jetty][:jetty_version] + "/webapps"  do
  to node[:jetty][:webapps_dir]
  owner node[:jetty][:user]
  group node[:jetty][:group]
end

#creating symbolic link
link opt_dir + node[:jetty][:jetty_version] + "/etc"  do
  to node[:jetty][:config_dir]
  owner node[:jetty][:user]
  group node[:jetty][:group]
end

link node[:jetty][:jetty_service] + "/jetty" do
  to opt_dir + node[:jetty][:jetty_version] + "/bin/jetty.sh"
  owner node[:jetty][:user]
  group node[:jetty][:group]
end

link opt_dir + "/jetty" do
  to opt_dir + node[:jetty][:jetty_version]
  owner node[:jetty][:user]
  group node[:jetty][:group]
end

template opt_dir + node[:jetty][:jetty_version] + "/etc/jetty.xml"  do
  source "jetty_config_xml.erb"
  owner node[:jetty][:user]
  group node[:jetty][:group]
  mode "0775"
  variables(
    :jetty_port => node[:jetty][:port]
  )
end

template opt_dir + node[:jetty][:jetty_version] + "/start.ini"  do
  source "jetty_java_options.erb"
  owner node[:jetty][:user]
  group node[:jetty][:group]
  mode "0775"
  variables(
    :jetty_java_options => node[:jetty][:java_options],
    :jetty_environment_var => node[:jetty][:java_environment_variables]
  )
end


ENV['MONGO_HOST'] = node[:jetty][:mongo_host]

service "jetty" do
  service_name "jetty"
  supports :restart => true, :status => true
  action [:enable, :start]
end

