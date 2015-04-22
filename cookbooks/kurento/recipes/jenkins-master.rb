#
# Cookbook Name:: kurento
# Recipe:: jenkins-master
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

apt_repository 'jenkins' do
  uri 'http://pkg.jenkins-ci.org/debian'
  distribution 'binary/'
end

package 'jenkins' do
	version '1.609'
end

user 'jenkins' do
	home '/var/lib/jenkins'
end

group 'jenkins' do
  members 'jenkins'
end

directory "/var/lib/jenkins/.ssh" do
  owner 'jenkins'
  group 'jenkins'
  mode 0755
  action :create
end

file "/var/lib/jenkins/.ssh/id_rsa" do
  owner 'jenkins'
  group 'jenkins'
  content data_bag_item('users', 'jenkins')['ssh_private_key']
  mode 0600
  action :create_if_missing
end

# Disable strict host checking. Accepts keys from all hosts
if not ::File.exists?("#{node['kurento']['home']}/.ssh/config") then
  file "#{node['kurento']['home']}/.ssh/config" do
    content "StrictHostKeyChecking no"
    action :create
    owner node['kurento']['user']
    group node['kurento']['group']
  end
else
  ruby_block "disable_host_key_verification" do
    block do
      file = Chef::Util::FileEdit.new("#{node['kurento']['home']}/.ssh/config")
      file.insert_line_if_no_match(/StrictHostKeyChecking no/, "StrictHostKeyChecking no")
      file.write_file
    end
  end
end

# Enable NTP
package 'cron'
cookbook_file 'ntpdate' do
  path "/etc/cron.hourly/ntpdate"
  mode '0755'
  action :create_if_missing
end
