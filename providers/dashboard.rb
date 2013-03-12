require 'yaml'

def load_current_resource
  @dashboard_dir = ::File.join(node['gdash']['templatedir'],
                             new_resource.category,
                             new_resource.name)

  @dashboard_yaml = ::File.join(@dashboard_dir,"dash.yaml")
end

use_inline_resources

action :create do
  service 'gdash' do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action :nothing
  end

  @dashboard_dir.sub("#{node['gdash']['templatedir']}/", '').split('/').inject([node['gdash']['templatedir']]){|memo,val|
    memo.push(::File.join(memo.last, val))
  }.each do |dir_path|
    directory dir_path do
      owner node['gdash']['owner']
      group node['gdash']['group']
      recursive true
      notifies :restart, 'service[gdash]', :delayed
    end
  end

  file @dashboard_yaml do
    owner node['gdash']['owner']
    group node['gdash']['group']
    content YAML.dump(
      :name => new_resource.display_name || new_resource.name,
      :description => new_resource.description
    )
  end
end

action :delete do
  service 'gdash' do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action :nothing
  end

  directory @dashboard_dir do
    action :delete
    notifies :restart, 'service[gdash]', :delayed
  end

  file @dashboard_yaml do
    action :delete
  end
end
