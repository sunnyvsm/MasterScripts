directory "#{node['vlg-nexus']['httpd_conf']}" do
  owner "root"
  group "root"
  mode "0755" 
  action :create
  not_if "test -a #{node['vlg-nexus']['httpd_conf']}"
end

template "#{node['vlg-nexus']['httpd_conf']}/nexus.videologygroup.com.conf" do
  source 'nexus.videologygroup.com.conf.erb'
  owner "root"
  group "root"
  mode "0644"
  action :create
  not_if "test -a #{node['vlg-nexus']['httpd_conf']}/nexus.videologygroup.com.conf"
  notifies :restart, "service[httpd]", :immediately
 end

service "httpd" do
  supports :restart => true, :reload => true
  action :enable
end
