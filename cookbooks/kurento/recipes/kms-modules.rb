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

version = node['kurento']['kurento-media-server']['package-version']
if Gem::Version.new(version) >= Gem::Version.new('6.0') 
  suffix = "-#{version}" 
else
  suffix = ""
end

# Public
package "kms-chroma#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package "kms-crowddetector#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package "kms-platedetector#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package "kms-pointerdetector#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end

# Private
package "kms-plumberendpoint#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade	
end
package "kms-background-extractor#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package "kms-face-segmentator#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
package "kms-markerdetector#{suffix}" do
	options "--allow-unauthenticated --force-yes"
	action :upgrade
end
