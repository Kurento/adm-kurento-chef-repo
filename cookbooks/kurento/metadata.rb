name             'kurento'
maintainer       'Kurento'
maintainer_email 'patxi.gortazar@gmail.com'
license          'LGPL 2.1'
description      'Installs/Configures kurento'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'git_user'
depends 'apt', ">= 2.0.0"
depends 'python'
depends 'ssh_known_hosts'
depends 'ssh-keys'
depends 'openssh'