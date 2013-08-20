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





#This code is here to help upgrade out installing process from jetty via eclipse to using debian packages.
#The jetty default cookbook used to download the jetty tgz from eclipse and set up symlinks to the extracted files.
#We now want to install the debian package instead so need to remove the old directores and symlinks.

if !File.symlink?("/etc/jetty/")

  Chef::Log.warn("Upgrading Jetty from to use Debian Package")
  directory "/etc/jetty" do
    action :delete
    recursive true
  end

end

if File.symlink?("/opt/jetty")

 Chef::Log.warn("Removing symlink to jetty version")
 
  directory "/opt/jetty" do
    action :delete
    recursive true
  end

  directory node[:jetty][:jetty_version] do
    action :delete
    recursive true
  end

  directory "/var/log/jetty" do
    action :delete
    recursive true
  end

  directory "/var/lib/jetty" do
    action :delete
    recursive true
  end

  
end
