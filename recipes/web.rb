include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

if node['gdash']['apache_auth']['realm'] != nil && \
  node['gdash']['apache_auth']['vhost_servername'] != nil && \
    node['apache_auth_group'] != nil

  include_recipe "apache2::mod_auth_digest"
  include_recipe "apache2::mod_rewrite"

  auth_users = search(:users, "groups:#{node['apache_auth_group']} AND pwdigest:*")

  template "#{node['apache']['dir']}/users.digest" do
    source "users.digest.erb"
    mode 0644
    owner "root"
    group "root"
    backup false
    variables(
      :users => auth_users
    )
  end

end

template "#{node['apache']['dir']}/sites-available/gdash" do
  source 'vhost.conf.erb'
  notifies :restart, 'service[apache2]'
end

apache_site 'gdash'
