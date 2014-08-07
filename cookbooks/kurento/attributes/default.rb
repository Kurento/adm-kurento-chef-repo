default['kurento']['user'] = "jenkins"
default['kurento']['group'] = "jenkins"
default['kurento']['home'] = "/var/lib/jenkins"
default['kurento']['email'] = "jenkins@acme.org"
default['kurento']['master-host'] = "ci.acme.org"
default['kurento']['kurento-media-server']['repositories']['release'] = true
default['kurento']['kurento-media-server']['repositories']['development'] = false
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