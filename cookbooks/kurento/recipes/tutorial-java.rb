#
# Cookbook Name:: kurento
# Recipe:: tutorial-java
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

directory "/tmp/tutorial-java/" do
  action :delete
  recursive true
  only_if { File.exists?("/tmp/tutorial-java") }
end

directory "/tmp/tutorial-java/" do
  action :create
end

%w{kurento-group-call kurento-hello-world kurento-magic-mirror kurento-one2many-call kurento-one2one-call kurento-one2one-call-advanced}.each do |tutorial|

  # TODO: Check for version in version property file, and re-install only if a new version is published. This way this recipe would be idempotent
  directory "/tmp/tutorial-java/#{tutorial}" do
    action :create
  end

  remote_file "/tmp/tutorial-java/#{tutorial}/#{tutorial}.zip" do
    source "http://builds.kurento.org/dev/latest/tutorials/#{tutorial}.zip"
  end

  execute "unzip_#{tutorial}" do
    cwd "/tmp/tutorial-java/#{tutorial}"
    command "unzip #{tutorial}.zip; chmod u+x install.sh"
  end

  execute "install_#{tutorial}" do
    cwd "/tmp/tutorial-java/#{tutorial}"
    command "./install.sh"
  end

  service tutorial do
    supports :start => true, :stop => true, :restart => true
    action :enable
  end
end
