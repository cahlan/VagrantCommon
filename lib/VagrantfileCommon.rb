
# we're going to do all the configuration through the Vagrant::Configuration singleton object,
# this will let multiple vagrantfiles all set up the configuration (that way you can have an easily
# updateable global config and a small adhoc vagrantfile for specific stuff)
require File.expand_path(File.join(File.dirname(__FILE__),"Vagrant"))

# this is how we can get the configuration singleton in any other vagrantfile
vconfig = Vagrant::Configuration.get

# add the default box to use
vconfig.setBox("oneiric64","http://dl.dropbox.com/u/3886896/oneiric64.box")

# add the default forwarded ports
vconfig.forwardPort(80, 10080)
vconfig.forwardPort(443, 10443)

# add the default shared folder, this will be the folder with the vagrant file in it,
# this will move up each folder until if finds the folder with the vagrantfile in it
vroot = File.expand_path(Dir.pwd)
catch (:done) do

  while true

    ["Vagrantfile","vagrantfile"].each do |vbasename|

      vf = File.join(vroot,vbasename)
      throw :done if File.exists?(vf)

    end

    vtemp = File.expand_path(File.join(vroot,".."))

    # we've reached root, there are no more folders to check, and we didn't find a vagrant file
    if(vtemp == vroot)
      raise "Could not find a Vagrantfile in \"#{Dir.pwd}\" or any parent directories"
    end

    vroot = vtemp

  end

end

vconfig.shareFolder("v-root","/vagrant",vroot)

# add default chef solo stuff, recipes will be added in the custom config file 
vconfig.addCookbookPath(File.expand_path(File.join(File.dirname(__FILE__),"..","cookbooks")))

# add the host machine user's ssh key to the vagrant user authorized_keys file
if(ENV.key?("HOME"))

  ssh_key_path = File.join(ENV["HOME"],".ssh","id_rsa.pub")
  
  if(File.exists?(ssh_key_path))
  
    ssh_public_key = File.open(ssh_key_path,"r").read
    
    vconfig.addRecipe("ssh-keys",{
      :ssh_keys => {
        :authorized_keys => {
          "localuser" => ssh_public_key
        }
      },
    })
    
  end

end
