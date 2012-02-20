
node[:reload] ||= {}
args = node[:reload]

cmd = "python /usr/bin/reload.py"

# build the command string from all the args that were passed in
if args.has_key?(:args)

  args[:args].each do |key,val|
  
     cmd += " --#{key} \"#{val}\""
  
  end

end

cmd += " -d &"

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
  command cmd
  user "root"
  group "root"
  action :run
  not_if "ps aux | grep -v \"grep\" | grep \"/usr/bin/reload.py\""
end
