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
# available config options: http://projects.unbit.it/uwsgi/wiki/Doc
node[:uwsgi] ||= {}
node[:uwsgi][:config] ||= {}

case node[:platform]
  
  when "debian", "ubuntu"
    
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
    #execute "pip install http://projects.unbit.it/downloads/uwsgi-1.0.4.tar.gz" do
      cwd Dir.tmpdir
      user "root"
      action :run
      #ignore_failure false
      not_if "test -f /usr/local/bin/uwsgi"
    end
    
    # create support folders
    dirs = [
      "/etc/uwsgi/apps-enabled",
      "/etc/uwsgi/apps-available",
      "/var/log/uwsgi"
    ]
    dirs.each do |dir|
      
      directory dir do
        owner "root"
        group "root"
        mode "0755"
        recursive true
        action :create
      end
      
    end
    
    # move the init script to the right place
    cookbook_file "/etc/init.d/uwsgi" do
      backup false
      source "uwsgi.sh"
      owner "root"
      group "root"
      mode "0755"
    end
    
    service "uwsgi" do
      service_name "uwsgi"
      supports :restart => true, :reload => true
    end
    
    # create ini files for each configuration
    count = 1
    node[:uwsgi][:config].each do |conf,settings|
    
      # set some defaults
      # available config options: http://projects.unbit.it/uwsgi/wiki/Doc
      settings["socket"] ||= "127.0.0.1:900#{count}"
      settings["workers"] ||= 2
      settings["uid"] ||= "www-data"
      settings["gid"] ||= "www-data"
      
      ["master","autoload","no-orphans","log-date","show-config"].each do |key|
      
        if !settings.has_key?(key)
          settings[key] = true
        end
      
      end
      
      count += 1
    
      template "/etc/uwsgi/apps-available/#{conf}.ini" do
        source "ini.erb"
        owner "root"
        group "root"
        mode "0644"
        variables(:config => settings)
        notifies :restart, resources(:service => "uwsgi"), :delayed
      end
      
      # activate the new config
      execute "ln -s /etc/uwsgi/apps-available/#{conf}.ini /etc/uwsgi/apps-enabled/#{conf}.ini" do
        user "root"
        action :run
        not_if "test -L /etc/uwsgi/apps-enabled/#{conf}.ini"
      end
    
    end

end
