#java
default['java']['jdk_version'] = '8'
#crucible
default['vlg-crucible']['version'] = '3.10.1'
default['vlg-crucible']['download_url'] = "https://downloads.atlassian.com/software/crucible/downloads/crucible-#{node['vlg-crucible']['version']}.zip"
default['vlg-crucible']['installation_path'] = '/opt/atlassian'
default['vlg-crucible']['home_path'] = '/opt/atlassian/crucible'
default['vlg-crucible']['root_dir'] = '/root/'
default['vlg-crucible']['checksum'] = 'b4301ff761999f6bf24ca321b7a8a9dd'
# user/group
default['vlg-crucible']['user'] = 'crucible'


#databse
default['vlg-crucible']['database']['type'] = 'postgresql'
default['vlg-crucible']['database']['host'] = 'localhost'
default['vlg-crucible']['database']['port'] = '5432'
default['vlg-crucible']['database']['name'] = 'crucible'
default['vlg-crucible']['database']['user'] = 'crucible'
default['vlg-crucible']['database']['password'] = 'root'

#apache proxy
default['vlg-crucible']['httpd_conf'] = '/etc/httpd/sites-available'
default['vlg-crucible']['apache2']['access_log']         = ''
default['vlg-crucible']['apache2']['error_log']          = ''
default['vlg-crucible']['apache2']['port']               = 80
default['vlg-crucible']['apache2']['virtual_host_alias'] = node['fqdn']
default['vlg-crucible']['apache2']['virtual_host_name']  = node['hostname']
default['vlg-crucible']['port']         = '8060'
