cookbook_file "/tmp/ifconfig.sh" do
  source "ifconfig.sh" 
  mode "0644"
end

execute "shell_script" do
  command "bash /tmp/ifconfig.sh"
  action :run
  ignore_failure true
end
