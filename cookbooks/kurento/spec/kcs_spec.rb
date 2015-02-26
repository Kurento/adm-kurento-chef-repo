require 'spec_helper'
require 'chefspec'

describe 'kurento::kcs' do
  let(:chef_run) { ChefSpec::Runner.new }

  it 'installs kcs from release' do
  	chef_run.node.set['kurento']['kurento-control-server']['download-url'] = 'http://builds.kurento.org/release/stable/kurento-control-server.zip'
  	chef_run.converge(described_recipe)
    
    expect(chef_run).to create_remote_file('/tmp/kcs/kurento-control-server.zip').with(source: 'http://builds.kurento.org/release/stable/kurento-control-server.zip')
  end

  it 'installs kcs from development' do
    chef_run.node.set['kurento']['kurento-control-server']['download-url'] = 'http://builds.kurento.org/dev/latest/kurento-control-server.zip'
  	chef_run.converge(described_recipe)
    
    expect(chef_run).to create_remote_file('/tmp/kcs/kurento-control-server.zip').with(source: 'http://builds.kurento.org/dev/latest/kurento-control-server.zip')
  end

end