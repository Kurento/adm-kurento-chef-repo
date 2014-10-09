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

# Install docker v>=1 with remote access to service on port 20023
execute "wget -qO- https://get.docker.io/gpg | sudo apt-key add - && touch /tmp/docker-key" do
	not_if { ::File.exists?("/tmp/docker-key")}
end

execute "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list " do
	not_if { ::File.exists?("/etc/apt/sources.list.d/docker.list")}
end

# Enable remote access to docker service on port 20023
execute "echo DOCKER_OPTS=\\\"-H tcp://0.0.0.0:20023 -H unix:///var/run/docker.sock\\\" > /etc/default/docker" do
	not_if { ::File.exists?("/tmp/docker-conf")}
end

execute 'apt-get update'

package 'docker.io'
execute 'ln -sf /usr/bin/docker.io /usr/local/bin/docker'

if ::File.exists?("/etc/bash_completion.d/docker.io")
	docker_completion = "/etc/bash_completion.d/docker.io"
else
	docker_completion = "/etc/bash_completion.d/docker"
end

ruby_block "bash completion for docker" do
 	block do
  		file = Chef::Util::FileEdit.new(docker_completion)
  		file.insert_line_if_no_match(/complete -F _docker docker/, "complete -F _docker docker")
  		file.write_file
	end
end

if ['i386', 'i486', 'i586', 'i686', 'x86'].include? node[:kernel][:machine]
	log 'Running on a x86 architecture. Will install a more recent version of docker to avoid https://github.com/docker/docker/issues/4556'
	execute 'update-rc.d docker defaults'
	execute "wget #{node['kurento']['docker-x86']['docker-deb-url']}" do
		not_if { ::File.exists?(node['kurento']['docker-x86']['docker-deb-url']) }
	end
	execute "wget #{node['kurento']['docker-x86']['dmsetup-deb-url']}" do
		not_if { ::File.exists?(node['kurento']['docker-x86']['dmsetup-deb-url']) }
	end
	execute "wget #{node['kurento']['docker-x86']['libdevmapper-deb-url']}" do
		not_if { ::File.exists?(node['kurento']['docker-x86']['libdevmapper-deb-url']) }
	end
	execute "echo 'debconf-set-selections debconf/frontend select noninteractive' | sudo debconf-set-selections"
	execute "dpkg -i *.deb && touch /tmp/docker-x86.installed" do
		not_if { ::File.exists?("/tmp/docker-x86.installed") }
	end
	execute 'docker pull i686/ubuntu'
else
	execute 'update-rc.d docker.io defaults'
	execute 'docker pull ubuntu:14.04'
end

# Secure docker service. Allow access only from CI master
execute 'iptables -F'
execute 'iptables -A INPUT -p tcp --dport 20023 -s ci.kurento.org -j ACCEPT'
execute 'iptables -A INPUT -p tcp --dport 20023 -j DROP'
