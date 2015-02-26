#
# Cookbook Name:: kurento
# Recipe:: kcs
#
# Copyright 2014, Kurento
#
# Licensed under the Lesser GPL, Version 2.1 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.gnu.org/licenses/lgpl-2.1.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory "/tmp/kcs/" do
  action :create
end

remote_file "/tmp/kcs/kurento-control-server.zip" do
  source "#{node['kurento']['kurento-control-server']['download-url']}"
end

execute "install_kcs" do
  cwd "/tmp/kcs"
  command "unzip -o kurento-control-server.zip; ./bin/install.sh"
end

service "kurento-control-server" do
  supports :start => true, :stop => true
  action :enable
end
