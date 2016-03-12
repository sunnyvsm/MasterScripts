#
# Cookbook Name:: cookbook1
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#




users = data_bag('users')

users.each do |login|
  myuser = data_bag_item('users', login)
  homedir = "/home/#{login}"
  sshdir = "/home/#{login}/.ssh"
  pubkeypath = "/home/#{login}/.ssh/id_rsa.pub"
  prikeypath = "/home/#{login}/.ssh/id_rsa"

  user(myuser) do
    uid 	myuser['uid']
    shell	myuser['shell']
    comment	myuser['comment']
    home 	homedir
    supports	:manage_home => true
    username	myuser['username']
  end	 
  
  directory 'create .ssh' do
    path sshdir
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
 
  file "/home/#{login}/.ssh/authorized_keys" do
    owner
    mode "0644"
    content myuser['key_content']    
    action :create
  end

end



group "cybadmin" do
  members "rama"
  action :create
end

template '/etc/sudoers' do
  source 'sudoers.erb'
  variables({
  	:sudoers_users => node[:authorization][:sudo][:users],
	:sudoers_groups => node[:authorization][:sudo][:groups],
	:passwordless => node[:authorization][:sudo][:passwordless]
  })	
  action :create
end 

bash 'disallow password login' do
  code "sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config"
  action :run
end

package node['apache']['package']

service node['apache']['package'] do
  action [ :enable, :start ]
end

template "#{node['document_root']}/index.html" do
  source "index.html.erb"
  action :create
end
