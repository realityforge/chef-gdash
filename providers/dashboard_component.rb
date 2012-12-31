def load_current_resource
  @dashboard_dir = ::File.join(
    node['gdash']['templatedir'],
    new_resource.dashboard_category,
    new_resource.dashboard_name
  )
end

notifying_action :create do
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

  template ::File.join(@dashboard_dir, "#{new_resource.name}.graph") do
    source 'gdash.graph.erb'
    cookbook 'gdash'
    template_hash = ::GDASH_RESOURCE_ATTRIBS.map{ |attr|
      if(new_resource.respond_to?(attr) && !new_resource.send(attr).nil?)
        [attr, new_resource.send(attr)]
      else
        nil
      end
    }.compact.flatten
    template_hash = Hash[*template_hash]

    owner node['gdash']['owner']
    group node['gdash']['group']
    mode 0644
    variables(
      :base_variables => template_hash,
      :fields => new_resource.fields || {},
      :lines => new_resource.lines || [],
      :forecasts => new_resource.forecasts || {}
    )
    action :create
  end
end

notifying_action :delete do
  service 'gdash' do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action :nothing
  end

  file ::File.join(@dashboard_dir, "#{new_resource.name}.graph") do
    action :delete
    notifies :restart, 'service[gdash]', :delayed
  end
end
