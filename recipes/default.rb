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
include_recipe "apt"

opt_dir = "/opt/jetty"

[
  "jetty-hightide-server"
].each { |pak|
   package pak  do
      action :install
   end
}

#creating a user to run under Jetty
user node[:jetty][:user] do
  comment "jetty user used to run jetty"
  shell "/bin/false"
end

group node[:jetty][:group] do
  members [ node[:jetty][:group]]
end

#remove all but a few files in the webapps folder.
bash "Removing files from webapps" do
  user "root"
  cwd "/opt"
  code <<-BASH_SCRIPT
  cd #{node[:jetty][:webapps_dir]}
  rm -rf root
  rm -rf test-*
  BASH_SCRIPT
end


template opt_dir + "/etc/jetty.xml"  do
  source "jetty_config_xml.erb"
  owner node[:jetty][:user]
  group node[:jetty][:group]
  mode "0775"
  variables(
    :jetty_port => node[:jetty][:port]
  )
end

template opt_dir + "/start.ini"  do
  source "jetty_java_options.erb"
  owner node[:jetty][:user]
  group node[:jetty][:group]
  mode "0775"
  variables(
    :jetty_java_options => node[:jetty][:java_options],
    :jetty_environment_var => node[:jetty][:java_environment_variables]
  )
end

if !File.symlink?("/etc/jetty/")
  
  directory "/etc/jetty" do
    action :delete
    recursive true
  end

  link node[:jetty][:config_dir] do
    to opt_dir + "/etc" 
    link_type :symbolic
    action :create
  end

end

ruby_block "update_opt_owner" do
   block do
      FileUtils.chown_R node[:jetty][:user], node[:jetty][:group], opt_dir
   end
   action :nothing
end

ENV['MONGO_HOST'] = node[:jetty][:mongo_host]



service "jetty" do
  service_name "jetty"
  supports :restart => true, :status => true
  notifies :create, "ruby_block[update_opt_owner]", :immediately
  action [:enable, :start]
end

