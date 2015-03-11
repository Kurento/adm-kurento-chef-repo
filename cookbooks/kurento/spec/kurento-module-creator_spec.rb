require 'spec_helper'
require 'chefspec'

describe 'kurento::kurento-module-creator' do
  let(:chef_run) { ChefSpec::Runner.new }

  it 'installs kurento-module-creator 3.0' do
  	chef_run.node.set['kurento']['kurento-module-creator']['package-version'] = '3.0'
  	chef_run.converge(described_recipe)
    
    expect(chef_run).to upgrade_package('kurento-module-creator')
  end

  it 'installs kurento-module-creator 4.0' do
  	chef_run.node.set['kurento']['kurento-module-creator']['package-version'] = '4.0'
  	chef_run.converge(described_recipe)
    
    expect(chef_run).to upgrade_package('kurento-module-creator-4.0')
  end

end