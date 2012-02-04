##
# This recipe will add a chef execute resource that will add any ssh keys that aren't
# currently in each of the local box user's authorized_keys file
# 
# currently, this only works for ubuntu boxes
#
# @since  12-5-11
##
if(node.key?(:ssh_keys) && node[:ssh_keys].key?(:authorized_keys))
  
  case node[:platform]
    
    when "debian", "ubuntu"
    
      dirs = Dir.glob("/home/*/")
      dirs << "/root/"
  
      dirs.each do |dir|

        ssh_file = File.join(dir,".ssh","authorized_keys")
        if(File.exists?(ssh_file))

          authorized_keys = File.open(ssh_file,"r").read
          
          node[:ssh_keys][:authorized_keys].each do |u,k|
            
            if(!authorized_keys.include?("#{k}"))
           
              # add the key to this user's authorized keys file
              execute "adding key for user #{u} to #{ssh_file}" do
                user "root"
                command "echo \"#{k}\" >> #{ssh_file}"
                action :run
              end
            
            end
            
          end
        
        end
      
      end
    
  end
  
end
