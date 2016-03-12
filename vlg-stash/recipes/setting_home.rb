template "#{node['stash']['install_path']}/stash/bin/setenv.sh" do
  source 'setenv.sh.erb'
  owner node['stash']['user']
  mode '0644'
  notifies :restart, 'service[stash]', :delayed
end
