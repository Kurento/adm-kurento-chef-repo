#
# Cookbook Name:: kurento
# Recipe:: kurento-sfu-room-demo
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

execute 'apt-get update'

package 'unzip'
package 'jshon'

# Unzip Kurento App
execute "unzip_kurento_app" do
  cwd "/tmp"
  command "unzip -o /tmp/kurento-app.zip"
end

# Install Kurento App with no automatic enable and start
execute "install_kurento_app" do
  cwd "/tmp"
  command "NOSTART=true NOENABLE=true ./bin/install.sh"
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

# Disable all services
service 'logstash' do
  action :disable
end
service 'td-agent' do
	action :disable
end
