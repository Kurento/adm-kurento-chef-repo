#
# Cookbook Name:: kurento
# Recipe:: jenkins-base
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

package 'unzip'
package 'nginx'
package 'jshon'

# Install Kurento Media Server
package 'kurento-media-server-6.0' do
  options "-y --allow-unauthenticated --force-yes"
  action :upgrade
end

# Disable automatic media server startup
service 'kurento-media-server-6.0' do
  action :disable
end

# install Kurento modules
package 'kms-s3'

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
