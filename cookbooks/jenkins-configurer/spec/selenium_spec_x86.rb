require 'spec_helper'
require 'chefspec'

describe 'jenkins-configurer::selenium' do

  kernel_release = '3.2.0-23-generic'

  let(:chef_run) do
     ChefSpec::Runner.new do |node| 
       node.automatic['lsb']['codename'] = 'trusty'
       node.automatic['kernel']['release'] = kernel_release
       node.automatic['kernel']['machine'] = 'x86'
     end.converge(described_recipe) 
  end

  it 'installs correct chrome package' do
    expect(chef_run).to run_execute("dpkg -i google-chrome-stable_current_i386.deb && touch /tmp/google-chrome")
  end

end