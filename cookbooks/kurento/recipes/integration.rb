#
# Cookbook Name:: kurento
# Recipe:: integration
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
service 'rabbitmq-server' do
	action [:enable , :start]
end

# Install old media server
package 'kurento' do
	options "--allow-unauthenticated --force-yes"
end

# Required to test KWS
package 'software-properties-common'
package 'python-software-properties'
apt_repository 'nodejs' do
  uri          'http://ppa.launchpad.net/chris-lea/node.js/ubuntu'
  distribution node['lsb']['codename']
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          'C7917B12'
end
package 'g++'
package 'make'
package 'nodejs'

package 'maven'

execute 'update-alternatives --set mvn /usr/share/maven/bin/mvn'

directory "#{node['kurento']['home']}/test-files" do
    action :delete
    recursive true
end

package 'subversion'
subversion "test-files" do
    repository "http://files.kurento.org/svn/kurento"
    revision "HEAD"
    destination "#{node['kurento']['home']}/test-files"
    user node['kurento']['user']
    group node['kurento']['user']
    action :sync
end