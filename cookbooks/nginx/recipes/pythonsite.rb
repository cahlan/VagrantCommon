##
# install a basic python site, this will have to install uwsgi also
#
# this is only for oneiric and newer Ubuntu servers
##

include_recipe "nginx::site"

node[:nginx][:socket] ||= '127.0.0.1:9001'

template "/etc/nginx/sites-available/pythonsite" do
  source "pythonsite.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
end

# activate the new config
execute "ln -s /etc/nginx/sites-available/pythonsite /etc/nginx/sites-enabled/pythonsite" do
  user "root"
  command "ln -s /etc/nginx/sites-available/pythonsite /etc/nginx/sites-enabled/pythonsite"
  action :run
  not_if "test -L /etc/nginx/sites-enabled/pythonsite"
end
