#
# Cookbook Name:: jenkins-configurer
# Recipe:: default
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

# v4l2loopback
package "linux-headers-#{node['kernel']['release']}"
package 'module-assistant'
package 'v4l2loopback-source'

execute 'm-a prepare'
execute 'm-a update'
execute 'm-a a-i v4l2loopback-source'

# It doesn't work, and it is not currently installed in jenkins nodes
execute 'modprobe v4l2loopback video_nr=1,2,3,4'
execute "echo 'v4l2loopback' >> /etc/modules" do
  not_if { ::File.exists?("/etc/modules")}
end

#In addition, the real video device (/dev/video0) should be disabled. To do that:
execute 'modprobe -r uvcvideo'