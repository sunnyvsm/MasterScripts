platform = 'windows' if node['platform_family'] == 'windows'
platform ||= 'linux'
settings = Stash.settings(node)

if node['platform_family'] == 'rhel' && node['platform_version'].to_f < 7
  include_recipe 'git::source'
else
  include_recipe 'git'
end
include_recipe 'perl'
include_recipe 'vlg-stash::stash_dir'
include_recipe 'stash::database'
include_recipe 'stash::linux_standalone'
include_recipe 'vlg-stash::stash_homedir_access_fix'
include_recipe 'stash::configuration'
include_recipe 'vlg-stash::setting_home'
include_recipe 'stash::apache2'
include_recipe 'stash::service_init'