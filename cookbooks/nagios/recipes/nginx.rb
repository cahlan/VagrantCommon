
include_recipe "nagios"

conf = "nagios"
node[:nagios][:socket] ||= '127.0.0.1:9000'
node[:nagios][:server_name] ||= 'localhost'
node[:nagios][:port] ||= 5052


package "spawn-fcgi" do
  action :upgrade
end

package "fcgiwrap" do
  action :upgrade
end

template "/etc/nginx/sites-available/#{conf}" do
  source "nagios.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
end

# activate the new config
execute "ln -s /etc/nginx/sites-available/#{conf} /etc/nginx/sites-enabled/#{conf}" do
  user "root"
  command "ln -s /etc/nginx/sites-available/#{conf} /etc/nginx/sites-enabled/#{conf}"
  action :run
  not_if "test -L /etc/nginx/sites-enabled/#{conf}"
end
