#
# Cookbook Name:: kurento
# Recipe:: kurento-module-creator
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

# Version 4 and above include the version in the package name
version = node['kurento']['kurento-module-creator']['package-version']
if Gem::Version.new(version) >= Gem::Version.new('4.0') 
	suffix = "-#{version}" 
else
	suffix = ""
end

# Install kurento-module-creator
package "kurento-module-creator#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end