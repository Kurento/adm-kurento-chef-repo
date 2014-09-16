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
execute "sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io"
execute 'update-rc.d docker.io defaults'
execute 'docker pull ubuntu'

# Secure docker service. Allow access only from CI master
execute 'iptables -F'
execute 'iptables -A INPUT -p tcp --dport 20023 -s ci.kurento.org -j ACCEPT'
execute 'iptables -A INPUT -p tcp --dport 20023 -j DROP'
