##
# installs pgbouncer for postgres
#
# since 6-14-12
##

# set some sensible defaults
node[:postgres] ||= {}

# configuration that will make its way to /etc/pgbouncer/pgbouncer.ini
# http://pgbouncer.projects.postgresql.org/doc/config.html
node[:postgres][:pgbouncer] ||= {}
node[:postgres][:pgbouncer][:databases] ||= {}
node[:postgres][:pgbouncer][:pgbouncer] ||= {}

# set default databases from the top level postgres node...
if node[:postgres].has_key?(:databases)

  node[:postgres][:databases].each do |username, db_list|
  
    db_list.each do |db_name|
    
      if !node[:postgres][:pgbouncer][:databases].has_key?(db_name)
      
        node[:postgres][:pgbouncer][:databases][db_name] = {
          "host" => "127.0.0.1",
          "port" => 5432
        }
        
      end
    
    end
  
  end  

end

{
  "listen_addr" => "127.0.0.1", # "*" might be better default
  "listen_port" => 6432,
  "pool_mode" => "transaction",
  "server_reset_query" => "DISCARD ALL",
  "max_client_conn" => 100,
  "default_pool_size" => 20,
  "log_connections" => 1, 
  "log_disconnections" => 1, 
  "log_pooler_errors" => 1,
  "server_check_delay" => 30,
  "server_lifetime" => 3600,
  "server_idle_timeout" => 600,
  "client_login_timeout" => 60,
  "auth_type" => "md5",
  "listen_backlog" => 200
}.each do |key, val| 

  if !node[:postgres][:pgbouncer][:pgbouncer].has_key?(key)
    node[:postgres][:pgbouncer][:pgbouncer][key] = val
  end

end

case node[:platform]
  
  when "debian", "ubuntu"
    
    package "pgbouncer" do
      action :upgrade
    end
    
    # http://wiki.opscode.com/display/chef/Resources#Resources-Service
    service "pgbouncer" do
      service_name "pgbouncer"
      supports :restart => true, :reload => false
      action :enable
    end
    
    template "/etc/pgbouncer/userlist.txt" do
      source "userlist.erb"
      owner "postgres"
      group "postgres"
      mode "0640"
      notifies :restart, resources(:service => "pgbouncer"), :delayed
    end
    
    # backup the original config, just in case?
    execute "cp /etc/pgbouncer/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini.bak" do
      user "root"
      action :run
      not_if "test -f /etc/pgbouncer/pgbouncer.ini.bak"
    end
    
    template "/etc/pgbouncer/pgbouncer.ini" do
      source "pgbouncer.erb"
      owner "postgres"
      group "postgres"
      mode "0640"
      notifies :restart, resources(:service => "pgbouncer"), :delayed
    end
    
    execute "activate pgbouncer" do
      user "root"
      action :run
      command "cd /etc/default; sed 's/START=0/START=1/' pgbouncer > pgbouncer2; mv pgbouncer2 pgbouncer"
    end
    
end
