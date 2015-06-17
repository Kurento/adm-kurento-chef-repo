#
# Cookbook Name:: kurento
# Recipe:: chef-testing
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

execute 'apt-get update'

execute "wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.6-1_amd64.deb"
#execute "wget http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.0-1_amd64.deb"
execute "dpkg -i chefdk_0.3.6-1_amd64.deb"

package 'ruby1.9.3'

# Necessary to build native gems
package 'ruby1.9.1-dev'
package 'build-essential'
package 'zlib'

gem_package 'berkshelf' do
	timeout	3600
	version "~> 3.2.3"
end

gem_package 'test-kitchen' do
	version "~> 1.3.1"
end
gem_package 'kitchen-docker' do
	version "~>	1.7.0"
end
gem_package 'foodcritic' do
	version "~> 4.0.0"
end
gem_package 'chefspec' do
	version "~> 3.4.0"
end
gem_package 'rspec_junit_formatter' do
	version "~> 0.1.6"
end
