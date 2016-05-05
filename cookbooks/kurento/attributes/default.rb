default['kurento']['user'] = "jenkins"
default['kurento']['group'] = "jenkins"
default['kurento']['home'] = "/var/lib/jenkins"
default['kurento']['email'] = "jenkins@acme.org"
default['kurento']['master-host'] = "ci.acme.org"
default['kurento']['docker']['version'] = '1.9.1-0~trusty'
default['kurento']['docker-compose']['version'] = '1.4.0'
default['kurento']['tutorial']['base-url'] = "http://builds.kurento.org/dev/release-5.1/latest/tutorials"
default['kurento']['tutorial']['packages'] =
	[
		'kurento-hello-world',
		'kurento-magic-mirror',
		'kurento-one2many-call',
		'kurento-one2one-call',
		'kurento-one2one-call-advanced'
	]
default['kurento']['demo']['base-url'] = "http://builds.kurento.org/dev/latest/demos"
default['kurento']['demo']['packages'] =
	[
		'kurento-crowddetector'
	]
default['kurento']['kurento-control-server']['download-url'] = 'http://builds.kurento.org/release/stable/kurento-control-server.zip'
default['kurento']['kurento-module-creator']['package-version'] = '3.0'
default['kurento']['kurento-media-server']['package-version'] = '5.0'
default['kurento']['kurento-media-server']['component'] = 'main'
default['kurento']['kurento-media-server']['repositories']['release'] = true
default['kurento']['kurento-media-server']['repositories']['development'] = false
default['kurento']['kurento-dev-media-server']['dependencies'] =
	[
		'debhelper',
		'cmake',
		'kms-core-dev',
		'libboost-dev',
		'libboost-system-dev',
		'libboost-filesystem-dev',
		'libthrift-dev',
		'thrift-compiler',
		'libevent-dev',
		'librabbitmq-dev',
		'libboost-test-dev',
		'kms-elements',
		'kms-filters'
	]
default['kurento']['kurento-dev-debian']['dependencies'] =
	[
		'git',
		'debhelper',
		'git-buildpackage',
		'debhelper',
		'devscripts',
		'kms-cmake-utils',
		'cmake',
		'libboost-dev',
		'libjsoncpp-dev',
		'pkg-config',
		'kurento-module-creator',
		'pkg-config',
		'kms-jsoncpp-dev',
		'libgstreamer1.0-dev',
		'libgstreamer-plugins-base1.0-dev',
		'libvpx-dev',
		'libsigc++-2.0-dev',
		'libglibmm-2.4-dev',
		'gstreamer1.0-plugins-base',
		'gstreamer1.0-libav',
		'gstreamer1.0-plugins-bad',
		'gstreamer1.0-plugins-good',
		'gstreamer1.0-plugins-ugly',
		'asn1c',
		'kms-core-dev',
		'libsoup2.4-dev',
		'libgnutls28-dev',
		'libsctp-dev',
		'kms-gstmarshal-dev',
		'uuid-dev',
		'gstreamer1.0-nice',
		'gnutls-bin',
		'libopencv-dev',
		'kms-elements'
	]
