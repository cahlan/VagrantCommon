##
# this installs php-fpm and common supporting packages
##

case node[:platform]
  
  when "debian", "ubuntu"
    
    package "php5-fpm" do
      action :upgrade
    end
    
    # install common supporting repositories...
    
    package "php5-cli" do
      action :upgrade
    end
     
    package "php5-curl" do
      action :upgrade
    end
 
    package "php5-mcrypt" do
      action :upgrade
    end
    
    package "php5-memcache" do
      action :upgrade
    end
    
    package "php5-sqlite" do
      action :upgrade
    end
    
    package "php5-mysql" do
      action :upgrade
    end
    
    package "php5-pgsql" do
      action :upgrade
    end
    
    package "php-pear" do
      action :upgrade
    end
    
    package "php5-suhosin" do
      action :upgrade
    end
    
    package "php-apc" do
      action :upgrade
    end
    
    # http://wiki.opscode.com/display/chef/Resources#Resources-Service
    service "php5-fpm" do
      service_name "php5-fpm"
      supports :restart => true, :reload => false
      action :enable
    end
    
    # I think this is deprecated, but php cli complains about it unless removed
    file "/etc/php5/conf.d/sqlite.ini" do
      action :delete
    end
    
end
