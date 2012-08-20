
case node[:platform]
  
  when "debian", "ubuntu"
    
    # install supporting repositories...
    
    package "nginx" do
      action :upgrade
      # not_if "test -d /etc/nginx"
    end
    
    # http://wiki.opscode.com/display/chef/Resources#Resources-Service
    service "nginx" do
      service_name "nginx"
      supports :restart => true, :reload => false
      action [:enable,:start]
    end
    
end

if node['nginx']['default_site_remove']

    # get rid of default configuration
    execute "remove default nginx server configuration" do
      user "root"
      command "rm /etc/nginx/sites-enabled/default"
      ignore_failure true
      not_if "test ! -L /etc/nginx/sites-enabled/default"
      action :run
    end
end
