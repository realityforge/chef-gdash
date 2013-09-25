#
# Copyright 2012, Sean Escriva <sean.escriva@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe 'build-essential'
include_recipe 'unicorn'

%w[libcurl4-gnutls-dev ruby1.9.1-full].each do |pkg|
  apt_package pkg
end

gem_package 'bundler' do
  gem_binary "/usr/bin/gem#{node['gdash']['rubyversion']}"
end

# We set these attributes here rather than in attributes files as it gives roles and environments the chance
# to override the attributes
node.override['gdash']['graphite_url'] = "http://#{node['graphite']['web']['host']}:#{node['graphite']['web']['port']}" unless node['gdash']['graphite_url']
node.override['gdash']['graphite_whisperdb'] = node['graphite']['whisper']['data_dir'] unless node['gdash']['graphite_whisperdb']
node.override['gdash']['owner'] = node['apache']['user'] unless node['gdash']['owner']
node.override['gdash']['group'] = node['apache']['group'] unless node['gdash']['group']

gdash_owner = node['gdash']['owner']
gdash_group = node['gdash']['group']

remote_file node['gdash']['tarfile'] do
  mode '00666'
  owner gdash_owner
  group gdash_group
  source node['gdash']['url']
  action :create_if_missing
end

directory node['gdash']['base'] do
  owner gdash_owner
  group gdash_group
end

directory File.join(node['gdash']['base'], 'templates') do
  owner gdash_owner
  group gdash_group
end

execute 'bundle' do
  command "bundle install --binstubs #{File.join(node['gdash']['base'], 'bin')} --path #{File.join(node['gdash']['base'], 'vendor', 'bundle')}"
  user gdash_owner
  group gdash_group
  cwd node['gdash']['base']
  creates File.join(node['gdash']['base'], 'bin')
  action :nothing
end

ruby_block 'bundle_unicorn' do
  block do
    gemfile = Chef::Util::FileEdit.new(
      File.join(node['gdash']['base'], 'Gemfile')
    )
    gemfile.insert_line_if_no_match(/unicorn/, 'gem "unicorn"')
    gemfile.write_file
  end
  notifies :run, 'execute[bundle]', :immediately
  not_if do
    File.exists?(File.join(node['gdash']['base'], 'Gemfile')) &&
    File.read(File.join(node['gdash']['base'], 'Gemfile')).include?('unicorn')
  end
  action :nothing
end

directory File.join(node['gdash']['base'], 'graph_templates', 'dashboards') do
  action :nothing
  recursive true
end

execute 'gdash: untar' do
  command "tar zxf #{node['gdash']['tarfile']} -C #{node['gdash']['base']} --strip-components=1"
  creates File.join(node['gdash']['base'], 'Gemfile.lock')
  user gdash_owner
  group gdash_group
  notifies :create, 'ruby_block[bundle_unicorn]', :immediately
  notifies :delete, "directory[#{File.join(node['gdash']['base'], 'graph_templates', 'dashboards')}]", :immediately
end

template File.join(node['gdash']['base'], 'config', 'gdash.yaml') do
  owner gdash_owner
  group gdash_group
  notifies :restart, 'service[gdash]'
end

directory node['gdash']['log_dir'] do
  owner gdash_owner
  group gdash_group
  mode 0755  
  recursive true
  action :create
end

unicorn_config '/etc/unicorn/gdash.app' do
  listen "#{node['gdash']['interface']}:#{node['gdash']['port']}" => {:backlog => 100}
  working_directory node['gdash']['base']
  worker_timeout 60
  preload_app false
  worker_processes 2
  stderr_path "#{node['gdash']['log_dir']}/#{node['gdash']['stderr_file']}"
  stdout_path "#{node['gdash']['log_dir']}/#{node['gdash']['stdout_file']}"
  owner 'root'
  group 'root'
end

template '/etc/init/gdash.conf' do
  source 'gdash-upstart.conf.erb'
  mode '0644'
  cookbook 'gdash'
end

service 'gdash' do
  provider Chef::Provider::Service::Upstart
  supports :start => true, :restart => true, :stop => true, :status => true
  action [:enable, :start]
end
