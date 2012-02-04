users_home = Dir.glob("/home/*/")
users_home << "/root/"

users_home.each do |user_home|

  user = File.basename(user_home)
  
  # http://wiki.opscode.com/display/chef/Resources#Resources-CookbookFile
  cookbook_file File.join(user_home,".bash_aliases") do
    backup false
    source "bash_aliases"
    owner user
    group user
    mode "0644"
  end
  
  cookbook_file File.join(user_home,".vimrc") do
    backup false
    source "vimrc"
    owner user
    group user
    mode "0644"
  end
  
end
