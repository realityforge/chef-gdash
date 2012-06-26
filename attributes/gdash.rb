default.gdash.tarfile = "/usr/src/gdash.tgz"
default.gdash.base = "/srv/gdash"
default.gdash.url = "https://github.com/ripienaar/gdash/tarball/master"

####
# WARN: pull in attributes from ANOTHER COOKBOOK
# TODO: put this in a databag ?
####
include_attribute "graphite::whisper"
include_attribute "graphite::web"
default.gdash.graphite_url = "http://#{node['graphite']['web']['host']}:#{node['graphite']['web']['port']}"
####

default.gdash.templatedir = "/srv/gdash/graph_templates"
default.gdash.owner = node['apache']['user']
default.gdash.group = node['apache']['group']
default.gdash.basic_auth = false
default.gdash.username = "gdash"
default.gdash.password = "gdash"
default.gdash.title = "Dashboard"
default.gdash.prefix = nil
default.gdash.refresh_rate = 60
default.gdash.columns = 2
default.gdash.graphite_whisperdb = node['graphite']['whisper']['data_dir']
default.gdash.port = 9292
default.gdash.interface = node[:ipaddress]
default.gdash.categories = []
default.gdash.dashboards = Mash.new
