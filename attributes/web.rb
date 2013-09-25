default['gdash']['web']['interface'] = node['ipaddress']
default['gdash']['web']['hostname'] = node['fqdn']
default['gdash']['web']['port'] = 80
# http://wiki.apache.org/httpd/CommonMisconfigurations
# see: Using the same Listen and/or NameVirtualHost multiple times.
# Thus, while a "required" directive (when using name-based virtual
# hosts) if this directive is already placed in /etc/apache2/ports.conf
# we want the ability to not duplicate it. This way we will avoid the warning
# 'NameVirtualHost *:80 has no VirtualHosts' by apache during startup.
default['gdash']['web']['should_put_namevirtualhost_directive_in_vhost_file'] = true

# apache_auth type = digest [apache2 (fronting unicorn) enabled];
# specify realm,vhost_servername & node.apache_auth_group to enable apache_auth;
# node's apache_auth_group is used to get matching users from
# data_bags/users (key='groups'). User also needs key='pwdigest'
# see http://httpd.apache.org/docs/2.2/programs/htdigest.html
default['gdash']['apache_auth']['realm'] = nil
default['gdash']['apache_auth']['vhost_servername'] = nil
default['gdash']['apache_auth']['vhost_server_aliases'] = nil
