#
# Cookbook Name:: kurento
# Recipe:: tutorial-js
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

# Install packages
package 'apache2'

# Install demos
directory "/tmp/kurento-tutorial-js/" do
  action :delete
  recursive true
  only_if { File.exists?("/tmp/kurento-tutorial-js") }
end

remote_file "/tmp/kurento-tutorial-js.zip" do
  source "http://builds.kurento.org/dev/latest/tutorials/kurento-tutorial-js.zip"
end

execute "unzip_kurento-tutorial-js" do
  cwd "/tmp"
  command "unzip -o kurento-tutorial-js.zip -d /var/www/html"
end


