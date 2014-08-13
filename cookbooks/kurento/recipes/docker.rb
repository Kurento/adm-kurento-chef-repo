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

# include_recipe 'apt'

# package 'apt-transport-https'

# apt_repository 'docker' do
#   uri          'https://get.docker.io/ubuntu'
#   distribution node['lsb']['codename']
#   components   ['main']
#   keyserver    'keyserver.ubuntu.com'
#   key          '36A1D7869245C8950F966E92D8576A8BA88D21E9'
# end

package 'wget'

execute "wget -qO- https://get.docker.io/gpg | sudo apt-key add - && touch /tmp/docker-key" do
	not_if { ::File.exists?("/tmp/docker-key")}
end

execute "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list && touch /tmp/docker-apt" do
	not_if { ::File.exists?("/tmp/docker-apt")}
end

execute "echo DOCKER_OPTS=\\\"-H tcp://0.0.0.0:20023 -H unix:///var/run/docker.sock\\\" > /etc/default/docker" do
	not_if { ::File.exists?("/tmp/docker-conf")}
end

execute 'apt-get update'

package 'lxc-docker'

# Secure docker network access
execute 'iptables -F'
execute 'iptables -A INPUT -p tcp --dport 20023 -s ci.kurento.org -j ACCEPT'
execute 'iptables -A INPUT -p tcp --dport 20023 -j DROP'

# Build kurento images
execute 'docker pull ubuntu:14.04'

directory '/tmp/kurento-docker' do
	action :delete
	recursive true
end

git '/tmp/kurento-docker' do
	action :checkout
	repository 'ssh://jenkins@repository.kurento.com:12345/adm-kurento-docker-repo'
	revision 'develop'
	user 'jenkins'
end

cookbook_file "build-kurento-docker-images" do
	path '/tmp/kurento-docker/build-kurento-docker-images'
	mode '0775'
	owner 'jenkins'
end

execute 'build-kurento-docker-images' do
	command '/tmp/kurento-docker/build-kurento-docker-images'
	cwd '/tmp/kurento-docker'
	timeout 14400
end

