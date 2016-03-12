template "nexus" do
  path "/etc/init.d/nexus"
  source 'nexus_service.erb'
  user "root"
  owner "root"
  mode "0755"
  not_if "test -a /etc/init.d/nexus"
  notifies :run, "bash[set_nexus_executable]", :immediately
  notifies :restart, "service[nexus]", :immediately
  end
  
  
bash "set_nexus_executable" do
user "root"
code <<-EOH
	chkconfig --add nexus
	chkconfig --levels 345 nexus on
EOH
end

service "nexus" do
    supports :restart => true, :start => true, :stop => true, :status => true
  action :enable
end  