#
# Cookbook Name:: vlg-cruc#ible
# Rec#ipe:: default
#
# Copyr#ight 2015, YOUR_COMPANY_NAME
#
# All r#ights reserved - Do Not Redistribute
include_recipe 'vlg-crucible::crucible_installation'
include_recipe 'vlg-crucible::crucible_config'
include_recipe 'vlg-crucible::httpd_conf'
include_recipe 'vlg-crucible::service_init'