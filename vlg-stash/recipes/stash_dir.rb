directory "#{node['stash']['home_path']}" do
  owner 'root'
  group 'root'
  mode 00755
  action :create
  recursive true
end
execute 'create keystroke file' do
  command '/bin/touch /var/atlassian/application-data/stash/.keystore'
end