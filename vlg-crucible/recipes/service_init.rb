template '/etc/init.d/crucible' do
  source 'crucible.init.erb'
  mode '0755'
  notifies :start, 'service[crucible]', :delayed
end

service 'crucible' do
  supports :status => true, :restart => true, :start => true
  action :start
  subscribes :start, 'java_ark[jdk]'
 end
