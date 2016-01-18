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
package 'curl'
execute 'curl -sSL https://get.docker.com/ | sh' do
  not_if { ::File.exists?('/usr/bin/docker') }
end

service "docker" do
  action :start
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Install docker-compose
execute 'curl -L https://github.com/docker/compose/releases/download/1.4.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose'
execute 'chmod +x /usr/local/bin/docker-compose'
execute "curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose --version | awk 'NR==1{print $NF}')/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

# Install dogestry to have an S3 backed docker repository
remote_file '/usr/bin/dogestry-linux-2.0.2' do
	source 'https://github.com/dogestry/dogestry/releases/download/v2.0.2/dogestry-linux-2.0.2'
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
link '/usr/bin/dogestry' do
  to '/usr/bin/dogestry-linux-2.0.2'
end

# Make docker listen on all ips
ruby_block "attach_docker_all_interfaces_and_enable_ipv6" do
  block do
    file = Chef::Util::FileEdit.new("/etc/default/docker")
    file.insert_line_if_no_match(/^DOCKER_OPTS/, "DOCKER_OPTS=\"-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock\" --ipv6 --fixed-cidr-v6=\"2001:db8:1::/64\"")
    file.write_file
  end
  notifies :restart, 'service[docker]', :immediately
end

# Change core pattern to core
ruby_block "set_core_pattern" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sysctl.conf")
    file.insert_line_if_no_match(/^kernel.core_pattern/, "kernel.core_pattern=core")
    file.write_file
  end
  notifies :restart, 'service[docker]', :immediately
end
