require 'spec_helper'
require 'chefspec'

describe 'kurento::docker' do

  let(:chef_run) do
     ChefSpec::Runner.new do |node| 
       node.automatic['kernel']['machine'] = 'i686'
     end.converge(described_recipe) 
  end

# Installs docker 1.2.0 using debs from debian
 it 'installs correct docker debs' do
   expect(chef_run).to run_execute("wget node['kurento']['docker-x86']['docker-deb-url']")
   expect(chef_run).to run_execute("wget node['kurento']['docker-x86']['libdevmapper-deb-url']")
   expect(chef_run).to run_execute("wget node['kurento']['docker-x86']['dmsetup-deb-url']")
   expect(chef_run).to run_execute("dpkg -i *.deb && touch /tmp/docker-x86.installed")
 end

end
