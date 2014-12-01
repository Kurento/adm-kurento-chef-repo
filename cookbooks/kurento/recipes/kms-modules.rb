#
# Cookbook Name:: kurento
# Recipe:: kms-modules
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

# Install required kms modules
# Public
package 'kms-chroma' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package 'kms-crowddetector' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package 'kms-platedetector' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package 'kms-pointerdetector' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end

# Private
package 'kms-background-extractor' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package 'kms-face-segmentator' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package 'kms-markerdetector' do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end