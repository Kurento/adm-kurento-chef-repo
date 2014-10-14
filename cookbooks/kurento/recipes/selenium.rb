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

# Install & configure xserver
package 'xserver-xorg'

file "#{node['kurento']['home']}/.bashrc" do
  action :create
  not_if { ::File.exists?("#{node['kurento']['home']}/.bashrc")}
end

ruby_block "export_display_on_bashrc" do
  block do
    file = Chef::Util::FileEdit.new("#{node['kurento']['home']}/.bashrc")
    file.search_file_delete_line(/export DISPLAY/)
    file.write_file
    file.insert_line_if_no_match(/export DISPLAY=0:0/, "export DISPLAY=0:0")
    file.write_file
  end
end

# Install utils
package 'mediainfo' 
package 'libxss1'
package 'xdg-utils'
package 'libpango1.0-0'
package 'libappindicator1'

# Install browsers
# Firefox
package 'firefox'

#Chrome
ruby_block "add_google_chrome_repo" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apt/sources.list")
    file.insert_line_if_no_match(/deb http:\/\/dl.google.com\/linux\/chrome\/deb\/ stable main/, "deb http://dl.google.com/linux/chrome/deb/ stable main")
    file.write_file
  end
end

# Add Google APT GPG key 
execute 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - '
execute 'apt-get update'
package 'google-chrome-stable'

# Add ffmpeg
apt_repository 'ffmpeg' do
  uri 'http://ppa.launchpad.net/jon-severinsson/ffmpeg/ubuntu'
  distribution node['lsb']['codename']
  components   ['main']
end

package 'ffmpeg' do
  options "--allow-unauthenticated --force-yes"
end
