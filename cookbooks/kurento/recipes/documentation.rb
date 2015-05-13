#
# Cookbook Name:: kurento
# Recipe:: documentation
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

# Install tools for building kurento documentation

include_recipe 'python'

%w{python-setuptools python-dev libxml2-dev libxslt-dev zlib1g-dev graphviz}.each do |pkg|
	package pkg
end

python_pip 'javasphinx'
python_pip 'lxml'
python_pip 'javalang'
python_pip 'docutils'
python_pip 'sphinx' do
	version "1.2.3"
end

package 'texlive-full' do
	timeout 3600
end

# Set locales.
# Docker build ignores this recipes and requires specific configuration in Dockerfile
cookbook_file 'locale' do
  action :create_if_missing
  path '/etc/default/locale'
  mode 0644
end
execute 'dpkg-reconfigure --frontend=noninteractive locales'
