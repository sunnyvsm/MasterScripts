directory "#{node['vlg-base']['app_user_home']}/sonatype-work/nexus/conf" do
  owner "#{node['vlg-base']['app_user']}"
  group "#{node['vlg-base']['app_user']}"
  mode "0755"
  action :create
  not_if "test -a #{node['vlg-base']['app_user_home']}/sonatype-work/nexus/conf"
end

template "#{node['vlg-base']['app_user_home']}/sonatype-work/nexus/conf/security.xml" do
  user "#{node['vlg-base']['app_user']}"
  source 'security.xml.erb'
  action :create
  not_if "test -a #{node['vlg-base']['app_user_home']}/sonatype-work/nexus/conf/security.xml"
end

template "#{node['vlg-base']['app_user_home']}/sonatype-work/nexus/conf/nexus.xml" do
  user "#{node['vlg-base']['app_user']}"
  source 'nexus.xml.erb'
  action :create
  not_if "test -a #{node['vlg-base']['app_user_home']}/sonatype-work/nexus/conf/nexus.xml"
end
