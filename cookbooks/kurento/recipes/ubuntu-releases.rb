#
# Cookbook Name:: kurento
# Recipe:: ubuntu-ppa
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

include_recipe 'apt'

# Kurento Media Server
apt_repository 'kurento' do
	uri          'http://ubuntu.kurento.org'
	distribution node['lsb']['codename']
	components   [ 'main', node['kurento']['kurento-media-server']['component'] ]
	keyserver    'keyserver.ubuntu.com'
  key          '2F819BC0'
end

execute 'apt-key update'
execute 'apt-get update'
