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

# canary
if(!node.has_key?(:ssh_keys))

  return
  
end
  
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
          
          # we use the script resource to obfuscate the keys being diplayed in debug mode
          script "adding public key for user #{username} to #{f}" do
            interpreter "bash"
            user username
            cwd "/tmp"
            code <<-EOH
            if [ $(grep "#{k}" "#{f}"; echo $?) -gt 0 ]; then
              echo "#{k}" >> #{f}
            fi
            EOH
          end
          
        end
        
      end
      
      # add any private keys
      {:rsa_key => 'id_rsa', :dsa_key => 'id_dsa'}.each do |priv_key, priv_filename|
      
        if(node[:ssh_keys].has_key?(priv_key))
      
          f = File.join(ssh_dir,priv_filename)
          k = node[:ssh_keys][priv_key]
          k.strip!
        
          # we use the script resource to obfuscate the keys being diplayed in debug mode
          script "adding #{priv_filename} for user #{username} to #{f}" do
            interpreter "bash"
            user username
            cwd "/tmp"
            code <<-EOH
            if [ ! -f "#{f}" ]; then
              echo "#{k}" > #{f}; chmod 600 #{f}
            fi
            EOH
          end
          
        end
      
      end
      
    end
    
end
    
