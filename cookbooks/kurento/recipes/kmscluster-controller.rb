#
# Cookbook Name:: kurento
# Recipe:: kmscluster-controller
#
# Copyright 2015, Kurento
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

# Provide access to private repository
bash 'apt-transport-s3' do
	user 'root'
	flags '-x'
	code <<-EOH
		wget http://ftp.de.debian.org/debian/pool/main/a/apt-transport-s3/apt-transport-s3_1.2.1-1_all.deb
		dpkg -i apt-transport-s3_1.2.1-1_all.deb
	EOH
end

cookbook_file 's3auth.conf' do
  owner 'root'
  group 'root'
  path '/etc/apt/s3auth.conf'
  mode 0600
  action :create_if_missing
end

apt_repository 'kurento-priv' do
	uri          's3://ubuntu-priv.kurento.org.s3.amazonaws.com'
	distribution node['kurento']['kurento-media-server']['distribution']
	components   [ node['kurento']['kurento-media-server']['component'] ]
	keyserver    'keyserver.ubuntu.com'
  key          '2F819BC0'
end

apt_repository 'kurento' do
	uri          'http://ubuntuci.kurento.org'
  distribution node['kurento']['kurento-media-server']['distribution']
	components   [ node['kurento']['kurento-media-server']['component'] ]
	keyserver    'keyserver.ubuntu.com'
  key          '2F819BC0'
end

execute 'apt-key update'
execute 'apt-get update'

package 'unzip'
package 'nginx'
package 'jshon'
package 'dkms'
package 'build-essential'

# Install Kurento Media Server
package 'kurento-media-server-6.0' do
  options "-y --allow-unauthenticated --force-yes"
  action :upgrade
end

# install Kurento modules
package 'kms-s3'
package 'kms-sfu'

# Remove access to private repository to avoid access during runtime
apt_repository 'kurento-priv' do
	uri          's3://ubuntu-priv.kurento.org.s3.amazonaws.com'
  action       :remove
end
execute 'apt-get update'

# Install Kurento KMS controller
execute "unzip_controller" do
  cwd "/tmp"
  command "unzip -o /tmp/kurento-kmscluster-controller.zip"
end

execute "install_controller" do
  cwd "/tmp/kurento-kmscluster-controller"
  command "./bin/install.sh"
end

# Install TURN server
remote_file "/tmp/turnserver-4.4.2.2-debian-wheezy-ubuntu-mint-x86-64bits.tar.gz" do
  source "http://turnserver.open-sys.org/downloads/v4.4.2.2/turnserver-4.4.2.2-debian-wheezy-ubuntu-mint-x86-64bits.tar.gz"
  mode "0755"
end

execute "untar_turn" do
  cwd "/tmp"
  command "tar xzf turnserver-4.4.2.2-debian-wheezy-ubuntu-mint-x86-64bits.tar.gz"
end

package 'libevent-core-2.0-5'
package 'libevent-extra-2.0-5'
package 'libevent-openssl-2.0-5'
package 'libevent-pthreads-2.0-5'
package 'libhiredis0.10'
package 'libmysqlclient18'
package 'libpq5'
execute "install_turn" do
  cwd "/tmp"
  command "dpkg -i coturn_4.4.2.2-1_amd64.deb"
end

ruby_block "enable_turnserver" do
  block do
    file = Chef::Util::FileEdit.new("/etc/default/coturn")
    file.search_file_replace_line(/^.*TURNSERVER_ENABLED.*$/, "TURNSERVER_ENABLED=1")
    file.write_file
  end
end

# Install AWS CLI
bash 'install_aws_cli' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -i /var/lib/aws -b /usr/bin/aws
  EOH
end

# Install AWS cnf
bash 'install_aws_cnf' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    AWS_CFN=/tmp/aws-cfn-bootstrap-latest
    curl https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.zip > $AWS_CFN.zip
    mkdir -p $AWS_CFN
    unzip -d $AWS_CFN $AWS_CFN.zip
    mkdir -p /opt/aws
    mv $AWS_CFN/$(ls $AWS_CFN)/* /opt/aws/
    (cd /opt/aws && python setup.py install)
    chmod o+x /opt/aws/bin/*
  EOH
end

# Install FluentD
bash 'limits' do
  user 'root'
  flags '-x'
  cwd '/tmp'
  code <<-EOH
    # Set limits
    sed -i 's/^.*soft nofile.*$//g' /etc/security/limits.conf
    sed -i 's/^.*hard nofile.*$//g' /etc/security/limits.conf
    echo "root soft nofile 500000" >> /etc/security/limits.conf
    echo "root hard nofile 500000" >> /etc/security/limits.conf
    echo "* soft nofile 500000" >> /etc/security/limits.conf
    echo "* hard nofile 500000" >> /etc/security/limits.conf
    # Install agent
    curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh
    # Install cloudwatch logs agent
    td-agent-gem install fluent-plugin-cloudwatch-logs
  EOH
end

# Install Logstash
bash 'logstash' do
  user 'root'
  flags '-x'
  code <<-EOH
    wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    echo "deb http://packages.elastic.co/logstash/2.1/debian stable main" | sudo tee -a /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install logstash
  EOH
end

# Configure network
bash 'sysctl' do
  user 'root'
  flags '-x'
  code <<-EOH
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.core.rmem_max = 33554432" >> /etc/sysctl.conf
    echo "net.core.wmem_max = 33554432" >> /etc/sysctl.conf
    echo "net.core.rmem_default = 1048576" >> /etc/sysctl.conf
    echo "net.core.wmem_default = 1048576" >> /etc/sysctl.conf
    echo "net.ipv4.udp_wmem_min = 1048576" >> /etc/sysctl.conf
    echo "net.ipv4.udp_rmem_min = 1048576" >> /etc/sysctl.conf
  EOH
end

# Install driver for enhanced networking in AWS
bash 'ixgbevf' do
  user 'root'
	cwd '/tmp'
  flags '-x'
  code <<-EOH
		mkdir work
		cd work
		wget http://sourceforge.net/projects/e1000/files/ixgbevf%20stable/2.16.1/ixgbevf-2.16.1.tar.gz
		tar zxf ixgbevf-2.16.1.tar.gz
		# https://gist.github.com/defila-aws/44946d3a3c0874fe3d17
		curl -L -O https://gist.github.com/defila-aws/44946d3a3c0874fe3d17/raw/af64c3c589811a0d214059d1e4fd220a96eaebb3/patch-ubuntu_14.04.1-ixgbevf-2.16.1-kcompat.h.patch
		cd ixgbevf-2.16.1/src
		patch -p5 <../../patch-ubuntu_14.04.1-ixgbevf-2.16.1-kcompat.h.patch
		dkms add -m ixgbevf -v 2.16.1
		dkms build -m ixgbevf -v 2.16.1
		dkms install -m ixgbevf -v 2.16.1
		update-initramfs -c -k all
		echo "options ixgbevf InterruptThrottleRate=1,1,1,1,1,1,1,1" > /etc/modprobe.d/ixgbevf.conf
	EOH
end

# Disable all services. Let cloud-init to start as required
service 'kurento-media-server-6.0' do
  action :disable
end
service 'kurento-kmscluster-controller' do
  action :disable
end
service 'nginx' do
  action :disable
end
service 'logstash' do
  action :disable
end
service 'td-agent' do
	action :disable
end
service 'coturn' do
	action :disable
end
