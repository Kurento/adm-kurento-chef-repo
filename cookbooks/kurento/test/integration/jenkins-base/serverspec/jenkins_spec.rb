require 'serverspec'

#include Serverspec::Helper::Exec
#include Serverspec::Helper::DetectOS

describe file('/var/lib/jenkins/.ssh/config') do
		it { should be_file }
    its(:content) { should match /Host code.kurento.org/ }
    its(:content) { should match /User jenkinskurento/ }
end

describe command('sudo -H -u jenkins bash -c "cd ~ ; git clone ssh://code.kurento.org:12345/adm-scripts"') do
  its(:exit_status) { should eq 0 }
end
