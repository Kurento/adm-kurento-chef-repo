#
# Cookbook Name:: kurento
# Recipe:: selenium
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

package 'xvfb'

cookbook_file '/etc/init.d/xvfb' do
  action :create
  mode   '0755'
end

execute 'add xvfb to the set of init scripts' do
  command 'update-rc.d xvfb defaults'
end

service 'xvfb' do
  action  :start
end

file "#{node['kurento']['home']}/.bashrc" do
  action :create
  not_if { ::File.exists?("#{node['kurento']['home']}/.bashrc")}
end

ruby_block "export_display_on_bashrc" do
  block do
    file = Chef::Util::FileEdit.new("#{node['kurento']['home']}/.bashrc")
    file.search_file_delete_line(/export DISPLAY/)
    file.write_file
    file.insert_line_if_no_match(/export DISPLAY=0:1/, "export DISPLAY=0:1")
    file.write_file
  end
end

package 'mediainfo' 
package 'firefox'

package 'libxss1'
package 'xdg-utils'

package 'wget'
package 'libpango1.0-0'
package 'libappindicator1'

if node['kernel']['machine'] == 'x86_64' then
  google_package_name = 'google-chrome-stable_current_amd64.deb'
else
  google_package_name = 'google-chrome-stable_current_i386.deb'
end

execute "wget https://dl.google.com/linux/direct/#{google_package_name}" do
  not_if { ::File.exists?(google_package_name)}
end

execute "install google chrome" do 
  command "dpkg -i #{google_package_name} && touch /tmp/google-chrome"
  not_if { ::File.exists?("/tmp/google-chrome")}
end
