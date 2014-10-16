#
# Cookbook Name:: kurento
# Recipe:: kms
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

# Disable IPV6
ruby_block "disable_ipv6" do
  block do
    file = Chef::Util::FileEdit.new("/etc/sysctl.conf")
    file.insert_line_if_no_match(/net.ipv6.conf.all.disable_ipv6 = 1/, "net.ipv6.conf.all.disable_ipv6 = 1")
    file.write_file
  end
end

# Install Kurento Media Server
package 'kurento-media-server' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end