##
# install uwsgi
#
# currently, this is only for oneiric and newer Ubuntu servers
# if node[:platform_version].to_f >= 11.10
#
# @link http://serverfault.com/questions/343050/uwsgi-and-nginx-for-python-apps-on-ubuntu-11-10
##

# set some defaults
node[:uwsgi] ||= {}
node[:uwsgi][:socket] ||= '127.0.0.1:9001'
node[:uwsgi][:options] ||= {}

case node[:platform]
  
  when "debian", "ubuntu"
    
    # uwsgi needs to be installed
    package "uwsgi" do
      action :upgrade
    end
    
    service "uwsgi" do
      service_name "uwsgi"
      supports :restart => true, :reload => false
      action [:enable,:start]
    end
    
end
