remote_file "#{Chef::Config[:file_cache_path]}/#{node['vlg-nexus']['packageNm']}" do
  action :create
  mode '0644'
  source "http://www.sonatype.org/downloads/#{node['vlg-nexus']['packageNm']}"
  checksum 'e3fe7811d932ef449fafc4287a27fae62127154297d073f594ca5cba4721f59e'
end

execute 'unzip_nexus' do
        user "#{node['vlg-base']['app_user']}"
        cwd "#{Chef::Config[:file_cache_path]}"
        command <<-EOF
        tar -xvf #{node['vlg-nexus']['packageNm']} -C #{node['vlg-base']['app_user_home']}
        mv #{node['vlg-base']['app_user_home']}/nexus* #{node['vlg-base']['app_user_home']}/nexus
        EOF
	not_if "test -a #{node['vlg-base']['app_user_home']}/nexus"
    action :run
end
