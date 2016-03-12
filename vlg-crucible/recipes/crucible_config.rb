config_path = "/root/config.xml"
case node['platform']
	when 'redhat' , 'centos', 'amazon', 'fedora'
		bash 'install_path' do
			user 'root'
			code <<-EOS
			echo "FISHEYE_INST=#{node['vlg-crucible']['home_path']}/crucible/" >> /etc/environment
			cp #{node['vlg-crucible']['home_path']}/config.xml /root
			EOS
			not_if {::File.exists?(config_path) }
					end	
end
