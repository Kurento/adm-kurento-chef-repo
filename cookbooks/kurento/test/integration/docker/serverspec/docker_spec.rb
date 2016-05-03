require 'serverspec'

#include Serverspec::Helper::Exec
#include Serverspec::Helper::DetectOS

describe package('docker-engine') do
  it { should be_installed.with_version('1.11.1-0~trusty') }
end

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe port(2375) do
  it { should be_listening }
end

describe command('docker --version') do
  its(:stdout) { should match /1.11/ }
  its(:exit_status) { should eq 0 }
end

describe user('vagrant') do
  it { should belong_to_group 'docker' }
end

describe file('/usr/local/bin/docker-compose') do
		it { should be_file }
end

describe file('/etc/default/docker') do
  its(:content) { should match /--insecure-registry dockerhub.kurento.org:5000/ }
end
