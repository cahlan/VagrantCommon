users_home = Dir.glob("/home/*/")
users_home << "/root/"

users_home.each do |user_home|

  user = File.basename(user_home)
  
  # http://wiki.opscode.com/display/chef/Resources#Resources-CookbookFile
  cookbook_file File.join(user_home,".bash_aliases") do
    backup false
    source "bash_aliases.sh"
    owner user
    group user
    mode "0644"
  end
  
  # only try and transfer the bash adhoc file if it exists, otherwise ignore it
  node.cookbook_collection["bash"].file_filenames.each do |f|
    
    if f.match(/bash_adhoc\.sh$/)
      
      cookbook_file File.join(user_home,".bash_adhoc") do
        backup false
        source "bash_adhoc.sh"
        owner user
        group user
        mode "0644"
        # ignore_failure true # this worked, but it threw errors in the log
      end
      
      break
      
    end
    
  end
  
  cookbook_file File.join(user_home,".vimrc") do
    backup false
    source "vimrc.sh"
    owner user
    group user
    mode "0644"
  end
  
end
