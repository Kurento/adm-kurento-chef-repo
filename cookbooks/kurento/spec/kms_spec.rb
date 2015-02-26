require 'spec_helper'
require 'chefspec'

describe 'kurento::kms' do
  let(:chef_run) { ChefSpec::Runner.new }

  it 'installs kms 5.0' do
  	chef_run.node.set['kurento']['kurento-media-server']['package-version'] = '5.0'
  	chef_run.converge(described_recipe)
    
    expect(chef_run).to upgrade_package('kurento-media-server')
  end

  it 'installs kms 6.0' do
  	chef_run.node.set['kurento']['kurento-media-server']['package-version'] = '6.0'
  	chef_run.converge(described_recipe)
    
    expect(chef_run).to upgrade_package('kurento-media-server-6.0')
  end

end

