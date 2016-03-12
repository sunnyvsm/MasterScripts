directory node['vlg-crucible']['installation_path'] do
  owner 'root'
  group 'root'
  mode 00755
  action :create
  recursive true
end

user node['vlg-crucible']['user'] do
  comment 'Crucible Service Account'
    shell '/bin/bash'
	home '/home'
  supports :manage_home => true
  system true
  action :create
end

ark "crucible" do
	url node['vlg-crucible']['download_url']
	version node['vlg-crucible']['version']
	prefix_root '/opt/atlassian'
   prefix_home '/opt/atlassian'
   action :install
   owner node['vlg-crucible']['user']
   group node['vlg-crucible']['user']
end   