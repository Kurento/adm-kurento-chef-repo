require 'spec_helper'

describe 'jenkins-configurer::selenium' do

  kernel_release = '3.2.0-23-generic'

  let(:chef_run) do
     ChefSpec::Runner.new do |node| 
       node.automatic['lsb']['codename'] = 'trusty'
       node.automatic['kernel']['release'] = kernel_release
       node.automatic['kernel']['machine'] = 'x86_64'
     end.converge(described_recipe) 
  end

  before do
    stub_data_bag(:users).and_return(['jenkins'])
    stub_data_bag_item(:users, 'jenkins').and_return({ id: 'jenkins', ssh_keys: "ssh-rsa test-key", ssh_private_key: "private", home: "/var/lib/jenkins", git_user: {enable: true, full_name: "jenkins", email: "jenkins@kurento.org" }})
    Fauxhai.mock(platform: "ubuntu", version: "14.04")
  end
 
  it 'installs package xvfb' do
    expect(chef_run).to install_package('xvfb')
  end

  it 'creates xvfb file from cookbook' do
    expect(chef_run).to create_cookbook_file('/etc/init.d/xvfb').with(mode: '0755')
  end

  it 'installs package mediainfo' do
    expect(chef_run).to install_package('mediainfo')
  end

  it 'installs package firefox' do
    expect(chef_run).to install_package('firefox')
  end

  it 'installs package maven' do
    expect(chef_run).to install_package('maven')
  end

end
