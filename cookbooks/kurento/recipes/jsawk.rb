#
# Cookbook Name:: kurento
# Recipe:: jsawk
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

## Install spidermonkey js
bash "install_js_sm" do
	user "root"
	code <<-EOH
		apt-get install mercurial autoconf2.13 -y
		cd /tmp
		hg clone http://hg.mozilla.org/mozilla-central spidermonkey
		cd spidermonkey/js/src 
		autoconf2.13
		./configure
		make
		sudo make install
	EOH
end

## Install jsawk
bash "install_js_awk" do
        user "root"
        code <<-EOH
		cd /tmp
		curl -L http://github.com/micha/jsawk/raw/master/jsawk > jsawk
		chmod 755 jsawk && mv jsawk /usr/bin/
	EOH
end
