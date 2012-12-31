include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

template "#{node['apache']['dir']}/sites-available/gdash" do
  source 'vhost.conf.erb'
  notifies :restart, resources(:service => 'apache2')
end

apache_site 'gdash'
