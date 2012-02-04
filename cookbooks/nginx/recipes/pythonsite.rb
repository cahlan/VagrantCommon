##
# install a basic python site that will interact using WSGI
#
# the template is for a WSGI python site, it's up to you install a WSGI server for nginx
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
