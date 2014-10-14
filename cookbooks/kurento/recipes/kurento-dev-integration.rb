#
# Cookbook Name:: kurento
# Recipe:: kurento-dev-integration
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

include_recipe 'kurento::rabbit'
# MongoDB server with default settings, ports 27017, 27018, 27019, 28017
include_recipe 'mongodb::default'

include_recipe 'kurento::ubuntu-ppa'
include_recipe 'kurento::ubuntu-repo'
include_recipe 'kurento::kms'
include_recipe 'kurento::maven'
include_recipe 'kurento::npm'
include_recipe 'kurento::test-files'
include_recipe 'kurento::selenium'
include_recipe 'kurento::documentation'

