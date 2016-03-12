execute "stash-permission" do
  command "chown -R stash:stash  /var/atlassian/application-data/stash/"
  user "root"
  action :run
 end