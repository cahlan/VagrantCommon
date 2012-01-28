##
# common configuration for the pythonsite and phpsite recipes
##

include_recipe "nginx"

# set some defaults
node[:nginx] ||= {}
node[:nginx][:server_name] ||= 'localhost'
# node[:nginx][:root] ||= '/vagrant'

# get rid of default configuration
execute "remove default nginx server configuration" do
  user "root"
  command "rm /etc/nginx/sites-enabled/default"
  ignore_failure true
  not_if "test ! -L /etc/nginx/sites-enabled/default"
  action :run
end
