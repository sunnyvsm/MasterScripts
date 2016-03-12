
default['authorization']['sudo']['users'] = ['rama','sama','dama']
default['authorization']['sudo']['groups'] = ['cybadmin']
default['authorization']['sudo']['passwordless'] = true

case node['platform']
when 'ubuntu'
default['apache']['package'] = "apache2"
default['document_root'] = "/var/www/"
when 'centos'
default['apache']['package'] = "httpd"
default['document_root'] = "/var/www/html/"
end
