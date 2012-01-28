##
# installs the postgresql db on ubuntu
#
# I found all the sql commands using this page: http://www.postgresql.org/docs/8.0/static/catalogs.html
# http://www.postgresql.org/docs/8.0/static/app-psql.html
# http://sqlrelay.sourceforge.net/sqlrelay/gettingstarted/postgresql.html
#
# this recipe is mainly for vagrant, for a more full featured recipe check out the official
# opscode one: http://community.opscode.com/cookbooks/postgresql and
# https://gist.github.com/637579
##


# set some defaults
node[:postgres] ||= {}
node[:postgres][:users] ||= {"postgres" => "postgres","vagrant" => "vagrant"} # username => password
node[:postgres][:databases] ||= {"vagrant" => "vagrant"} # dbname => username

case node[:platform]
  
  when "debian", "ubuntu"
    
    # install supporting repositories...
    
    package "python-software-properties" do
      action :upgrade
    end
    
    execute "add-apt-repository ppa:pitti/postgresql; apt-get update" do
      user "root"
      action :run
      #ignore_failure true
      not_if "which psql"
    end
    
    # package "postgresql-9.1" do
    package "postgresql" do
      action :upgrade
    end
    
    # package "postgresql-contrib-9.1" do
    package "postgresql-contrib" do
      action :upgrade
    end
    
    # add the postgres users and passwords
    node[:postgres][:users].each do |username,password|
    
      # add the user
      cmd = "sudo -u postgres createuser -D -S -R -e -w %s" % [username]
      not_cmd = "sudo -u postgres psql -c \"select usename from pg_user where usename='%s'\" -d template1 | grep \"%s\"" % [username,username]
      execute cmd do
        user "root"
        action :run
        #ignore_failure true
        not_if not_cmd
      end
      
      # set the user's password
      cmd = "sudo -u postgres psql -c \"ALTER USER %s WITH PASSWORD '%s'\" -d template1" % [username,password]
      not_cmd = "sudo -u postgres psql -c \"select rolpassword from pg_authid where rolname='%s'\" -d template1 | grep -x \" $\"" % [username]
      execute cmd do
        user "root"
        action :run
        #ignore_failure true
        only_if not_cmd
      end
    
    end
    
    # add databases
    node[:postgres][:users].each do |dbname,username|

      cmd = "sudo -u postgres createdb -E UNICODE -O %s %s" % [username,dbname]
      not_cmd = "sudo -u postgres psql -c \"select datname from pg_database where datname='%s'\" -d template1 | grep \"%s\"" % [dbname,dbname]
      execute cmd do
        user "root"
        action :run
        #ignore_failure true
        not_if not_cmd
      end
    
    end
    
    # http://wiki.opscode.com/display/chef/Resources#Resources-Service
    service "postgres" do
      service_name "postgresql"
      supports :restart => true, :reload => false
      action :enable
    end
    
end
