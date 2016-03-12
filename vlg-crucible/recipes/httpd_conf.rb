include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

apache_module 'auth_basic' do
  enable false
end
#directory "#{node['vlg-crucible']['httpd_conf']}" do
#  owner "root"
#  group "root"
#  mode "0755" 
#  action :create
#  end

template "#{node['vlg-crucible']['httpd_conf']}/cruible.videologygroup.com.conf" do
  source 'crucible.videologygroup.com.conf.erb'
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[httpd]", :immediately
 end
 
link '/etc/httpd/sites-enabled/cruible.videologygroup.com.conf' do
  to "#{node['vlg-crucible']['httpd_conf']}/cruible.videologygroup.com.conf"
  link_type :symbolic
end
 
service "httpd" do
  supports :restart => true, :reload => true
  action :enable
end
