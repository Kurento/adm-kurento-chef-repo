#
# Cookbook Name:: kurento
# Recipe:: maven
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

# Install maven
package 'maven'
execute 'update-alternatives --set mvn /usr/share/maven/bin/mvn'

# Add Kurento's gnupg keys
remote_directory "#{node['kurento']['home']}/.gnupg" do
  mode        0700
  owner       node['kurento']['user']
  group       node['kurento']['group']
  files_owner node['kurento']['user']
  files_group node['kurento']['group']
  source      ".gnupg"
end
