##
# This recipe will add a chef execute resource that will add any ssh keys that aren't
# currently in each of the local box user's authorized_keys file
# 
# currently, this only works for ubuntu boxes
#
# @link http://en.wikipedia.org/wiki/Ssh-keygen
# 
# @since  12-5-11
##
if(node.has_key?(:ssh_keys))
  
  case node[:platform]
    
    when "debian", "ubuntu"
    
      dirs = Dir.glob("/home/*/")
      dirs << "/root/"
  
      dirs.each do |dir|

        username = File.basename(dir)
        ssh_dir = File.join(dir,".ssh")

        directory ssh_dir do
          owner username
          group username
          mode "0700"
          action :create
        end

        # add any public keys to the authorized keys file
        if(node[:ssh_keys].has_key?(:public_keys))
  
          f = File.join(ssh_dir,"authorized_keys")
            
          Array(node[:ssh_keys][:public_keys]).each do |k|
            
            k.strip!
            
            # add the key to this user's authorized keys file
            execute "adding public key for user #{username} to #{f}" do
              user username
              command "echo \"#{k}\" >> #{f}"
              action :run
              not_if "grep \"#{k}\" \"#{f}\""
            end
            
          end
          
        end
        
        # add any private rsa keys
        if(node[:ssh_keys].has_key?(:rsa_key))
        
          f = File.join(ssh_dir,"id_rsa")
          k = node[:ssh_keys][:rsa_key]
          k.strip!
        
          execute "adding rsa key for user #{username} to #{f}" do
            user username
            command "echo \"#{k}\" > #{f}; chmod 600 #{f}"
            action :run
            not_if "test -f \"#{f}\""
          end
          
        end
        
        # add any privage dsa key
        if(node[:ssh_keys].has_key?(:dsa_key))
        
          f = File.join(ssh_dir,"id_dsa")
          k = node[:ssh_keys][:dsa_key]
          k.strip!
        
          execute "adding dsa key for user #{username} to #{f}" do
            user username
            command "echo \"#{k}\" > #{f}; chmod 600 #{f}"
            action :run
            not_if "test -f \"#{f}\""
          end
          
        end
        
      end
    
  end
  
end
