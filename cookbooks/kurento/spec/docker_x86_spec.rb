require 'spec_helper'
require 'chefspec'

describe 'kurento::docker' do

  let(:chef_run) do
     ChefSpec::Runner.new do |node| 
       node.automatic['kernel']['machine'] = 'i686'
       node.set['kurento']['docker-x86']['docker-deb-url'] = "http://ftp.es.debian.org/debian/pool/main/d/docker.io/docker.io_1.2.0~dfsg1-1_i386.deb"
	   node.set['kurento']['docker-x86']['libdevmapper-deb-url'] = "http://ftp.es.debian.org/debian/pool/main/l/lvm2/dmsetup_1.02.90-2_i386.deb"
	   node.set['kurento']['docker-x86']['dmsetup-deb-url'] = "http://ftp.es.debian.org/debian/pool/main/l/lvm2/libdevmapper1.02.1_1.02.90-2_i386.deb"
     end.converge(described_recipe) 
  end

# Installs docker 1.2.0 using debs from debian
 it 'installs correct docker debs' do
   expect(chef_run).to run_execute("wget http://ftp.es.debian.org/debian/pool/main/d/docker.io/docker.io_1.2.0~dfsg1-1_i386.deb")
   expect(chef_run).to run_execute("wget http://ftp.es.debian.org/debian/pool/main/l/lvm2/dmsetup_1.02.90-2_i386.deb")
   expect(chef_run).to run_execute("wget http://ftp.es.debian.org/debian/pool/main/l/lvm2/libdevmapper1.02.1_1.02.90-2_i386.deb")
   expect(chef_run).to run_execute("dpkg -i *.deb && touch /tmp/docker-x86.installed")
 end

end
