#
# Cookbook Name:: jenkins-configurer
# Recipe:: default
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

user node['jenkins-configurer']['user'] do
  home node['jenkins-configurer']['home']
  supports :manage_home => true
end

group node['jenkins-configurer']['group'] do
  members node['jenkins-configurer']['user']
end

# This seems like a hack, but it isn't. See https://tickets.opscode.com/browse/OHAI-389
node.automatic_attrs[:etc][:passwd][node['jenkins-configurer']['user']] = {:uid => node['jenkins-configurer']['user'], :gid => node['jenkins-configurer']['group'], :dir => node['jenkins-configurer']['home']}

ruby_block "add_jenkins_user_to_sudoers" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sudoers")
    file.insert_line_if_no_match(/jenkins/, "jenkins    ALL = NOPASSWD:SETENV:  /usr/bin/apt-get, /etc/init.d/kurento, /bin/kill, /usr/bin/killall, /bin/netstat, /var/lib/jenkins/kurento-media-connector/support-files/kmf-media-connector.sh")
    file.write_file
  end
end

directory "#{node['jenkins-configurer']['home']}/.ssh" do
  owner node['jenkins-configurer']['user']
  group node['jenkins-configurer']['group']
  mode 0755
  action :create
end

file "#{node['jenkins-configurer']['home']}/.ssh/id_rsa" do
  owner node['jenkins-configurer']['user']
  group node['jenkins-configurer']['group']
  content data_bag_item('users', 'jenkins')['ssh_private_key']
  mode 0600
  action :create
end

if not ::File.exists?("#{node['jenkins-configurer']['home']}/.ssh/config") then
  file "#{node['jenkins-configurer']['home']}/.ssh/config" do
    content "StrictHostKeyChecking no"
    action :create
    owner node['jenkins-configurer']['user']
    group node['jenkins-configurer']['group']
  end
else
  ruby_block "disable_host_key_verification" do
    block do
      file = Chef::Util::FileEdit.new("#{node['jenkins-configurer']['home']}/.ssh/config")
      file.insert_line_if_no_match(/StrictHostKeyChecking no/, "StrictHostKeyChecking no")
      file.write_file
    end
  end
end

include_recipe 'git_user'

git_user node['jenkins-configurer']['user'] do
  login     node['jenkins-configurer']['user']
  home      node['jenkins-configurer']['home']
  full_name node['jenkins-configurer']['user']
  email     node['jenkins-configurer']['email']
end

ssh_known_hosts_entry node['jenkins-configurer']['master-host']

include_recipe 'ssh-keys'

# Enable signing maven artifacts with gnupg
remote_directory "#{node['jenkins-configurer']['home']}/.gnupg" do
  mode        0700
  owner       node['jenkins-configurer']['user']
  group       node['jenkins-configurer']['group']
  files_owner node['jenkins-configurer']['user']
  files_group node['jenkins-configurer']['group']
  source      ".gnupg"
end

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

cookbook_file "#{node['jenkins-configurer']['home']}/.npmrc" do
  owner   node['jenkins-configurer']['user']
  group   node['jenkins-configurer']['group']
  mode    0644
end

package 'expect'

bash "npm adduser" do
  code <<-EOF
    /usr/bin/expect -c 'spawn npm adduser
    expect "Username: "
    send "#{node['jenkins-configurer']['npm']['username']}\r"
    expect "Password: "
    send "#{node['jenkins-configurer']['npm']['password']}\r"
    expect "Email: (this IS public) "
    send "#{node['jenkins-configurer']['npm']['email']}\r"
    expect eof'
    touch /tmp/npm-adduser
    EOF
  cwd node['jenkins-configurer']['home']
  user node['jenkins-configurer']['user']
  group node['jenkins-configurer']['group']
  environment ({'HOME' => node['jenkins-configurer']['home']})
  not_if { ::File.exists?("/tmp/npm-adduser")}
end

# file "/tmp/npm-credentials" do
#   action :delete
# end

# Utility to extract version from documentation
remote_directory "#{node['jenkins-configurer']['home']}/tools/jenkins-job-creator" do
  mode        0777
  owner       node['jenkins-configurer']['user']
  group       node['jenkins-configurer']['group']
  files_owner node['jenkins-configurer']['user']
  files_group node['jenkins-configurer']['group']
  files_mode  0775
  source      "jenkins-job-creator"
end
