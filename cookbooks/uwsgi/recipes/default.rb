##
# install uwsgi
#
# currently, this is only for oneiric and newer Ubuntu servers
# if node[:platform_version].to_f >= 11.10
#
# @link http://serverfault.com/questions/343050/uwsgi-and-nginx-for-python-apps-on-ubuntu-11-10
##

# need this to get the temp directory using Dir.tmpdir
require "tmpdir"

# set some defaults
node[:uwsgi] ||= {}
node[:uwsgi][:config] ||= {}
# available config options: http://projects.unbit.it/uwsgi/wiki/Doc
node[:uwsgi][:config]["socket"] ||= '127.0.0.1:9001'
# this is set to true in the default.ini when installing from repository
# if !node[:uwsgi][:config].has_key?("master")
#   node[:uwsgi][:config]["master"] = true
# end

case node[:platform]
  
  when "debian", "ubuntu"
    
    # we're going to install the default to get all the init files and everything
    # and then upgrade it using the latest build
    
    package "uwsgi" do
      action :upgrade
    end
    
    # we need a couple packages in order to install the latest uwsgi server
    package "libxml2-dev" do
      action :upgrade
    end
    
    package "python-pip" do
      action :upgrade
    end
    
    package "python2.7-dev" do
      action :upgrade
    end
    
    # this installs to usr/local/bin/uwsgi
    execute "pip install http://projects.unbit.it/downloads/uwsgi-latest.tar.gz" do
      cwd Dir.tmpdir
      user "root"
      action :run
      #ignore_failure false
      not_if "diff /usr/bin/uwsgi /usr/local/bin/uwsgi"
    end
    
    execute "cp /usr/local/bin/uwsgi /usr/bin/" do
      cwd Dir.tmpdir
      user "root"
      action :run
      #ignore_failure false
      not_if "diff /usr/bin/uwsgi /usr/local/bin/uwsgi"
    end
    
    service "uwsgi" do
      service_name "uwsgi"
      supports :restart => true, :reload => false
      action [:enable,:start]
    end
    
end
