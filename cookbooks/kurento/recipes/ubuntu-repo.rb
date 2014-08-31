#
# Cookbook Name:: kurento
# Recipe:: ubuntu-repo
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

ruby_block "add_kurento_repo" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apt/sources.list")
    file.insert_line_if_no_match(/deb http:\/\/ubuntu.kurento.org repo/, "deb http://ubuntu.kurento.org repo/")
    file.write_file  
  end
end  

# Add Google repo for google chrome
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
