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

version = node['kurento']['kurento-media-server']['package-version']
if Gem::Version.new(version) >= Gem::Version.new('6.0')
  suffix = "-#{version}"
else
  suffix = ""
end

# Kill all media server instances
execute "kill_kms" do
  command "killall -9 kurento-media-server#{suffix}"
  only_if { File.exists?("/usr/bin/killall") }
  ignore_failure true
end

# Install kms dependencies first to allow upgrading these
package "kms-jsonrpc-1.0" do
  options "--allow-unauthenticated --force-yes"
  action :upgrade
end

package "kms-core-#{suffix}" do
  options "--allow-unauthenticated --force-yes"
  action :upgrade
end

package "kms-elements-#{suffix}" do
  options "--allow-unauthenticated --force-yes"
  action :upgrade
end

package "kms-filters-#{suffix}" do
  options "--allow-unauthenticated --force-yes"
  action :upgrade
end

# Install Kurento Media Server
package "kurento-media-server#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end

service "kurento-media-server#{suffix}" do
  action :start
end
