##
# install python support for uwsgi
##

include_recipe "uwsgi"

node[:uwsgi][:config]["plugins"] ||= []
node[:uwsgi][:config]["plugins"] << "python"

package "uwsgi-plugin-python" do
  action :upgrade
end

template "/etc/uwsgi/apps-available/python.ini" do
  source "python.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "uwsgi"), :delayed
end

# activate the new config
execute "ln -s /etc/uwsgi/apps-available/python.ini /etc/uwsgi/apps-enabled/python.ini" do
  user "root"
  action :run
  not_if "test -L /etc/uwsgi/apps-enabled/python.ini"
end
