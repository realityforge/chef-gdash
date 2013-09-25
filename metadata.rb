name             'gdash'
maintainer       'Peter Donald'
maintainer_email 'Peter@realityforge.org'
license          'Apache 2.0'
description      'Installs/Configures gdash'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.4'

depends 'build-essential'
depends 'graphite'
depends 'unicorn'

suggests 'iptables'

# Required for apache_site recipe
suggests 'apache2'
