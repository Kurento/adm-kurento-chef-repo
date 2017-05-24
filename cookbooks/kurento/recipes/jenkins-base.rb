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

# Update hostname in /etc/host to allow name resolution in openstack
ruby_block "update_hosts" do
  block do
    file = Chef::Util::FileEdit.new("/etc/hosts")
    file.insert_line_if_no_match(/#{node['hostname']}/, "127.0.0.1   #{node['hostname']}")
    file.write_file
  end
end

# Configure Kurento's apt proxy if necessary
execute "echo \"Acquire::http::Proxy \\\"http://ubuntu.kurento.org:3142\\\";\" > /etc/apt/apt.conf.d/01proxy" do
  not_if { ::File.exists?('/etc/apt/apt.conf.d/01proxy') }
end
ruby_block "add_proxy_if_necessary" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apt/apt.conf.d/01proxy")
    file.insert_line_if_no_match(/ubuntu.kurento.org:3142/, "Acquire::http::Proxy \\\"http://ubuntu.kurento.org:3142\\\";")
    file.write_file
  end
end
ruby_block "bypass_proxy_nodesource" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apt/apt.conf.d/01proxy")
    file.insert_line_if_no_match(/deb.nodesource.com/, "Acquire::HTTP::Proxy::deb.nodesource.com \\\"DIRECT\\\";")
    file.write_file
  end
end
ruby_block "bypass_proxy_dockerproject" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apt/apt.conf.d/01proxy")
    file.insert_line_if_no_match(/apt.dockerproject.org/, "Acquire::HTTP::Proxy::apt.dockerproject.org \\\"DIRECT\\\";")
    file.write_file
  end
end
ruby_block "bypass_proxy_nova" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apt/apt.conf.d/01proxy")
    file.insert_line_if_no_match(/nova.clouds.archive.ubuntu.com/, "Acquire::HTTP::Proxy::nova.clouds.archive.ubuntu.com \\\"DIRECT\\\";")
    file.write_file
  end
end

execute "apt-get update" do
  ignore_failure true
end

# Disable IPV6
ruby_block "disable_ipv6" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sysctl.conf")
    file.insert_line_if_no_match(/net.ipv6.conf.all.disable_ipv6 = 1/, "net.ipv6.conf.all.disable_ipv6 = 1")
    file.write_file
  end
end

# Fix locales if needed
execute 'locale-gen es_ES es_ES.UTF-8'
execute 'dpkg-reconfigure locales'

# Install openssh and create directory /var/run/sshd
package 'openssh-server'
directory '/var/run/sshd' do
  action :create
  recursive true
end

# Needed for adm-scripts
package 'realpath'

# Install xmlstarlet
package 'xmlstarlet'

# Install jshon
# Only available since Ubuntu 14.04 Trusty Tahr
if platform?("ubuntu")
  if node['platform_version'] == "14.04"
    package 'jshon'
  end
end

# Install expect
package 'expect'

# Install wget
package 'wget'

# Install Java
# Install JDK without fuse (path for docker containers)
package 'default-jdk' do
  action :install
  options "--no-install-recommends"
end

# Install software-properties-common (required to add PPAs)
package 'software-properties-common'
package 'python-software-properties'

package 'unzip'
package 'zip'

ohai 'reload_passwd' do
  action :nothing
  plugin 'passwd'
end

# Create user & group jenkins
user node['kurento']['user'] do
  home node['kurento']['home']
  shell '/bin/bash'
  supports :manage_home => true
  notifies :reload, 'ohai[reload_passwd]', :immediately
end

group node['kurento']['group'] do
  members node['kurento']['user']
  notifies :reload, 'ohai[reload_passwd]', :immediately
end

# This seems like a hack, but it isn't. See https://tickets.opscode.com/browse/OHAI-389
#node.automatic_attrs[:etc][:passwd][node['kurento']['user']] = {:uid => node['kurento']['user'], :gid => node['kurento']['group'], :dir => node['kurento']['home']}



# Install git and configure user
include_recipe 'git_user'
git_user node['kurento']['user'] do
  login     node['kurento']['user']
  home      node['kurento']['home']
  full_name node['kurento']['user']
  email     node['kurento']['email']
end

# Add user jenkins to sudoers
ruby_block "add_jenkins_user_to_sudoers" do
  block do
    found = false
    File.open("/etc/sudoers") do |f|
      f.each_line do |line|
        if line =~ /jenkins/
          found = true
        end
      end
    end
    file = Chef::Util::FileEdit.new("/etc/sudoers")
    if found
      file.search_file_replace_line(/jenkins/, "jenkins    ALL=(ALL) NOPASSWD: ALL")
    else
      file.insert_line_if_no_match(/jenkins/, "jenkins    ALL=(ALL) NOPASSWD: ALL")
    end
    file.write_file
  end
end

# Add jenkins private key & certificate
directory "#{node['kurento']['home']}/.ssh" do
  owner node['kurento']['user']
  group node['kurento']['group']
  mode 0755
  action :create
end

# Needed for reprepro
cookbook_file 'jenkins.crt' do
  owner node['kurento']['user']
  group node['kurento']['group']
  path "#{node['kurento']['home']}/.ssh/jenkins.crt"
  mode 0600
  action :create_if_missing
end

template "#{node['kurento']['home']}/.ssh/config" do
  source 'config.erb'
  owner node['kurento']['user']
  group node['kurento']['group']
  mode '0644'
end

# Add public key from master
ssh_known_hosts_entry node['kurento']['master-host']
include_recipe 'ssh-keys'

# Add private key from master
user = data_bag_item('users', 'jenkins')
file "#{node['kurento']['home']}/.ssh/id_rsa" do
  content "#{user['ssh_private_key']}"
  mode 0600
  owner node['kurento']['user']
  group node['kurento']['group']
  action :create
end

# Add Kurento's gnupg keys
remote_directory "#{node['kurento']['home']}/.gnupg" do
  mode        0700
  owner       node['kurento']['user']
  group       node['kurento']['group']
  files_owner node['kurento']['user']
  files_group node['kurento']['group']
  source      ".gnupg"
end

# Enable NTP
package 'cron'
cookbook_file 'ntpdate' do
  path "/etc/cron.hourly/ntpdate"
  mode '0755'
  action :create_if_missing
end
