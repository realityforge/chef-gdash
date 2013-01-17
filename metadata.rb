name             "gdash"
maintainer       "Heavy Water Software Inc."
maintainer_email "ops@hw-ops.com"
license          "Apache 2.0"
description      "Installs/Configures gdash"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"

depends 'cutlery', '~> 0.1'

depends "build-essential"
depends "graphite"
depends "unicorn"

suggests "iptables"

# Required for apache_site recipe
suggests "apache2"
