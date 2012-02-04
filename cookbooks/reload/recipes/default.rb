
# http://wiki.opscode.com/display/chef/Resources#Resources-CookbookFile
cookbook_file "/usr/bin/reload.py" do
  backup false
  source "reload.py"
  owner "root"
  group "root"
  mode "0755"
end

# http://wiki.opscode.com/display/chef/Resources#Resources-Service
execute "reload-monitor" do
  command "python /usr/bin/reload.py --dir \"#{node[:reload][:dir]}\" --cmd \"#{node[:reload][:cmd]}\" -d &"
  user "root"
  group "root"
  action :run
end
