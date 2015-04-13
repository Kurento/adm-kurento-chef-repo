require 'spec_helper'

describe 'kurento::selenium' do
  let(:chef_run) do 
    ChefSpec::Runner.new do |node|
      node.set['kurento']['npm']['username'] = 'jenkins'
      node.set['kurento']['npm']['password'] = 'jenkins'
      node.set['kurento']['npm']['email'] = 'jenkins@kurento.org'
    end.converge(described_recipe)
  end

  before do
    stub_data_bag(:users).and_return(['jenkins'])
    stub_data_bag_item(:users, 'jenkins').and_return({ id: 'jenkins', ssh_keys: "ssh-rsa test-key", ssh_private_key: "private", home: "/var/lib/jenkins", git_user: {enable: true, full_name: "jenkins", email: "jenkins@kurento.org" }})
    Fauxhai.mock(platform: "ubuntu", version: "14.04")
  end

  it 'installs ffmpeg package on ubuntu 14.04' do
    expect(chef_run).to install_package('ffmpeg')
  end
end