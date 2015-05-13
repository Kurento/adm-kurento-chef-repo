#
# Cookbook Name:: kurento
# Recipe:: rabbit
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

package 'rabbitmq-server'
execute 'enable rabbitmq_management' do
	command 'rabbitmq-plugins enable rabbitmq_management'
	notifies :restart, "service[rabbitmq-server]", :delayed
	not_if { ::File.readlines("/etc/rabbitmq/enabled_plugins").grep(/rabbitmq_management/).size > 0 }
end
service 'rabbitmq-server' do
	action [:enable , :start]
end