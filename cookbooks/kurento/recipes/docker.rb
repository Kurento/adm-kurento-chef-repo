#
# Cookbook Name:: kurento
# Recipe:: docker
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

# See https://github.com/docker/docker/issues/9592
ruby_block "bypass_proxy_dockerproject" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apt/apt.conf.d/01proxy")
    file.insert_line_if_no_match(/apt.dockerproject.org/, "Acquire::HTTP::Proxy::apt.dockerproject.org \\\"DIRECT\\\";")
    file.write_file
  end
end

group 'docker' do
	members node['kurento']['user']
end

# Install docker-engine
package 'apt-transport-https'
package 'ca-certificates'
apt_repository 'docker-engine' do
  uri 'https://apt.dockerproject.org/repo'
  distribution 'ubuntu-trusty'
  components ['main']
  key '58118E89F3A912897C070ADBF76221572C52609D'
  keyserver 'hkp://p80.pool.sks-keyservers.net:80'
  action :add
end
execute "apt-get update" do
  ignore_failure true
end
package 'docker-engine' do
  version node['kurento']['docker']['version']
  options '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
  action :install
  notifies :restart, 'service[docker]', :delayed
end

service "docker" do
  action [:enable, :start]
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Install docker-compose
package 'curl'
execute "curl -L https://github.com/docker/compose/releases/download/#{node['kurento']['docker-compose']['version']}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
execute 'chmod +x /usr/local/bin/docker-compose'
execute "curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose --version | awk 'NR==1{print $NF}')/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

# Make docker listen on all ips and accept insecure registry
ruby_block "attach_docker_all_interfaces_and_enable_ipv6" do
  block do
    if File.readlines("/etc/default/docker").grep(/^DOCKER_OPTS/).size > 0
      file = Chef::Util::FileEdit.new("/etc/default/docker")
      file.search_file_replace_line(/^DOCKER_OPTS/, "DOCKER_OPTS=\"-H tcp://0.0.0.0:2375 --mtu 1450 -H unix:///var/run/docker.sock --insecure-registry dockerhub.kurento.org:5000 --ipv6 --fixed-cidr-v6=\"2001:db8:1::/64\"\"")
      file.write_file
    else
      file = Chef::Util::FileEdit.new("/etc/default/docker")
      file.insert_line_if_no_match(/^DOCKER_OPTS/, "DOCKER_OPTS=\"-H tcp://0.0.0.0:2375 --mtu 1450 -H unix:///var/run/docker.sock --insecure-registry dockerhub.kurento.org:5000 --ipv6 --fixed-cidr-v6=\"2001:db8:1::/64\"\"")
      file.write_file
    end
  end
  notifies :restart, 'service[docker]', :delayed
end

# Change core pattern to core
ruby_block "set_core_pattern" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sysctl.conf")
    file.insert_line_if_no_match(/^kernel.core_pattern/, "kernel.core_pattern=core")
    file.write_file
  end
  notifies :restart, 'service[docker]', :delayed
end

# For assigning ips to containers dynamically
package 'bridge-utils'
