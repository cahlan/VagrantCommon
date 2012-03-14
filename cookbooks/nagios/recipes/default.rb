##
# setup nagios
# 
# author -- Jay Marcyes
# since -- 3-12-12
# 
# this was primarily built with this link:
# http://vladgh.com/blog/nagios-nginx-ubuntu
# 
# I haven't implemented the plugins part yet.
# 
# other good links:
# http://johan.cc/2012/02/06/nagios-nginx/
# http://nagios.sourceforge.net/docs/nagioscore/3/en/quickstart-ubuntu.html
##

node[:nagios] ||= {}
node[:nagios][:prefix] ||= "/etc/nagios"

nagios_tar = "/tmp/nagios.tar.gz"
nagios_plugin_tar = "/tmp/nagios-plugins.tar.gz"

case node[:platform]
  
  when "debian", "ubuntu"
    
    # install supporting repositories...
    
    package "libc6" do
      action :upgrade
    end
    
    package "libperl5.10" do
      action :upgrade
    end
    
    package "perl" do
      action :upgrade
    end
    
    package "libgd2-xpm-dev" do
      action :upgrade
    end
    
    # add nagios user and groups
    # http://wiki.opscode.com/display/chef/Resources#Resources-User
    # http://askubuntu.com/questions/80444/how-to-set-user-passwords-using-passwd-without-a-prompt
    user "nagios" do
      comment "nagios user"
      system true
      shell "/bin/false"
    end
    
    group "nagios" do
      members ['nagios']
    end
    
    group "nagcmd" do
      members ['nagios','www-data']
    end
    
    # grab nagios and supporting files
    # http://www.nagios.org/download/core/thanks/
    remote_file nagios_tar do
      source "http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.3.1.tar.gz"
      backup 1
      mode "0644"
    end
    
    # http://www.nagios.org/download/plugins/
#     remote_file nagios_plugin_tar do
#       source "http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.15.tar.gz"
#       mode "0644"
#       checksum "08da002l" # A SHA256 (or portion thereof) of the file.
#     end
    
    script "install_nagios" do
      interpreter "bash"
      user "root"
      cwd "/tmp"
      not_if "test -d /etc/nagios"
      code <<-EOH
      tar -zxf #{nagios_tar}
      cd nagios
      ./configure --prefix #{node[:nagios][:prefix]} --with-command-group=nagcmd
      make all
      make install
      make install-init
      make install-config
      make install-commandmode
      EOH
    end
    
    # todo: configure /opt/nagios/etc/objects/contacts.cfg
    
    # make sure this directory is there
    # http://wiki.opscode.com/display/chef/Resources#Resources-Directory
    directory "#{node[:nagios][:prefix]}/var/spool/checkresults" do
      mode "0755"
      owner "nagios"
      group "nagios"
      action :create
      recursive true
    end
    
    execute "update-rc.d -f nagios defaults" do
      user "root"
      ignore_failure true
      not_if "test -d /etc/init.d/nagios"
      action :run
    end
    
    # you can check config with this command: /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg
    
    # http://wiki.opscode.com/display/chef/Resources#Resources-Service
    service "nagios" do
      service_name "nagios"
      supports :restart => true, :reload => false
      action [:enable,:start]
    end
    
end
