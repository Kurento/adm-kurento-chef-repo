#
# Cookbook Name:: kurento
# Recipe:: jenkins-base
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

include_recipe 'openssh'

execute "echo \"Acquire::http::Proxy \\\"http://ubuntu.kurento.org:3142\\\";\" > /etc/apt/apt.conf.d/01proxy"

directory '/var/run/sshd' do
  action :create
  recursive true
end

user node['kurento']['user'] do
  home node['kurento']['home']
  supports :manage_home => true
end

group node['kurento']['group'] do
  members node['kurento']['user']
end

# This seems like a hack, but it isn't. See https://tickets.opscode.com/browse/OHAI-389
node.automatic_attrs[:etc][:passwd][node['kurento']['user']] = {:uid => node['kurento']['user'], :gid => node['kurento']['group'], :dir => node['kurento']['home']}

ruby_block "add_jenkins_user_to_sudoers" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sudoers")
    file.insert_line_if_no_match(/jenkins/, "jenkins    ALL=(ALL)NOPASSWD: ALL")
    file.write_file
  end
end

directory "#{node['kurento']['home']}/.ssh" do
  owner node['kurento']['user']
  group node['kurento']['group']
  mode 0755
  action :create
end

file "#{node['kurento']['home']}/.ssh/id_rsa" do
  owner node['kurento']['user']
  group node['kurento']['group']
  content data_bag_item('users', 'jenkins')['ssh_private_key']
  mode 0600
  action :create_if_missing
end

cookbook_file 'jenkins.crt' do
  owner node['kurento']['user']
  group node['kurento']['group']
  path "#{node['kurento']['home']}/.ssh/jenkins.crt"
  mode 0600
  action :create_if_missing
end

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

include_recipe 'git_user'

git_user node['kurento']['user'] do
  login     node['kurento']['user']
  home      node['kurento']['home']
  full_name node['kurento']['user']
  email     node['kurento']['email']
end

package "git-review"

ssh_known_hosts_entry node['kurento']['master-host']

include_recipe 'ssh-keys'

# Enable signing maven artifacts with gnupg
remote_directory "#{node['kurento']['home']}/.gnupg" do
  mode        0700
  owner       node['kurento']['user']
  group       node['kurento']['group']
  files_owner node['kurento']['user']
  files_group node['kurento']['group']
  source      ".gnupg"
end

package "default-jdk"
package "xmlstarlet"

# Only available since Ubuntu 14.04 Trusty Tahr
if platform?("ubuntu")
  if node['platform_version'] == "14.04"
    package "jshon"
  end
end

ruby_block "disable_ipv6" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sysctl.conf")
    file.insert_line_if_no_match(/net.ipv6.conf.all.disable_ipv6 = 1/, "net.ipv6.conf.all.disable_ipv6 = 1")
    file.write_file
  end
end

cookbook_file "#{node['kurento']['home']}/.npmrc" do
  owner   node['kurento']['user']
  group   node['kurento']['group']
  mode    0644
end

package 'expect'

bash "npm adduser" do
  code <<-EOF
    /usr/bin/expect -c 'spawn npm adduser
    expect "Username: "
    send "#{node['kurento']['npm']['username']}\r"
    expect "Password: "
    send "#{node['kurento']['npm']['password']}\r"
    expect "Email: (this IS public) "
    send "#{node['kurento']['npm']['email']}\r"
    expect eof'
    touch /tmp/npm-adduser
    EOF
  cwd node['kurento']['home']
  user node['kurento']['user']
  group node['kurento']['group']
  environment ({'HOME' => node['kurento']['home']})
  not_if { ::File.exists?("/tmp/npm-adduser")}
end

# Utility to extract version from documentation
remote_directory "#{node['kurento']['home']}/tools/jenkins-job-creator" do
  mode        0777
  owner       node['kurento']['user']
  group       node['kurento']['group']
  files_owner node['kurento']['user']
  files_group node['kurento']['group']
  files_mode  0775
  source      "jenkins-job-creator"
end

file "/etc/cron.hourly/ntpdate" do
  content "ntpdate ntp.ubuntu.com"
  mode 755
  action :create
end
