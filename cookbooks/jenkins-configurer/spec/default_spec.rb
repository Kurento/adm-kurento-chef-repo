require 'spec_helper'
require 'chefspec'

describe 'jenkins-configurer::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    stub_data_bag(:users).and_return(['jenkins'])
    stub_data_bag_item(:users, 'jenkins').and_return({ id: 'jenkins', ssh_keys: "ssh-rsa test-key", ssh_private_key: "private", home: "/var/lib/jenkins", git_user: {enable: true, full_name: "jenkins", email: "jenkins@kurento.org" }})
    Fauxhai.mock(platform: "ubuntu", version: "14.04")
  end
  
  it 'creates jenkins user' do
    expect(chef_run).to create_user('jenkins')
  end

  it 'creates home directory' do
    expect(chef_run).to create_user('jenkins').with(home: '/var/lib/jenkins')
  end

  it 'installs git package' do
    expect(chef_run).to install_package('git')
  end

  it 'installs jshon package on ubuntu 14.04' do
    expect(chef_run).to install_package('jshon')
  end

end
