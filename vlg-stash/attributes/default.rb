#stash version
default['stash']['version']      = '3.10.0'
default['stash']['home_path']    = '/var/atlassian/application-data/stash'
default['stash']['install_path'] = '/opt/atlassian'
default['stash']['install_type'] = 'standalone'
default['stash']['service_type'] = 'init'

# postgresql
#data = Chef::EncryptedDataBagItem.load("bamboo-server", "db")
#postgresql_root_password = data["root-password"]
default['stash']['database']['name']     = 'stash'
default['stash']['database']['password']  = 'root'
default['stash']['database']['testInterval'] = 2
default['stash']['database']['type']     = 'postgresql'
default['stash']['database']['user']     = 'postgres'
default['postgresql']['password']['postgres'] = 'root'

#stash backup client
default['stash']['backup_client']['password'] = 'root'
