#
# Cookbook Name:: kurento
# Recipe:: kurento-demo
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

# Install Java JRE headless
package 'default-jre-headless' do
  action :install
end

include_recipe 'kurento::ubuntu-ppa'
include_recipe 'kurento::ubuntu-repo'
include_recipe 'kurento::kms'
include_recipe 'kurento::kms-modules'
include_recipe 'kurento::tutorial-java'
