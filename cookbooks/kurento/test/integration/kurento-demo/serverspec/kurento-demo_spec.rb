require 'serverspec'

#include Serverspec::Helper::Exec
#include Serverspec::Helper::DetectOS

describe package('kurento-media-server') do
  it { should be_installed }
end

describe service('kurento-media-server') do
  it { should be_enabled }
  it { should be_running }
end

describe port(8888) do
  it { should be_listening }
end

tutorials = {
	"kurento-hello-world" => 8081,
	"kurento-magic-mirror" => 8082,
	"kurento-one2many-call" => 8083,
	"kurento-one2one-call" => 8084,
	"kurento-one2one-call-advanced" => 8085
}

tutorials.each do |name,port|

	describe file("/tmp/tutorial-java/#{name}") do
  		it { should be_directory }
	end

	describe service("#{name}") do
  		it { should be_enabled }
  		it { should be_running }
	end

	describe port(port) do
  		it { should be_listening }
	end

end
