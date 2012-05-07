
# we're going to do all the configuration through the Vagrant::Configuration singleton object,
# this will let multiple vagrantfiles all set up the configuration (that way you can have an easily
# updateable global config and a small adhoc vagrantfile for specific stuff)
require File.expand_path(File.join(File.dirname(__FILE__),"Vagrant"))

# this is how we can get the configuration singleton in any other vagrantfile
vconfig = Vagrant::Configuration.get

# add the default box to use
#vconfig.setBox("oneiric64","http://dl.dropbox.com/u/3886896/oneiric64.box")
vconfig.setBox("precise64","http://dl.dropbox.com/u/21885077/ubuntu-12.04-server-amd64.box")

# add the default forwarded ports
vconfig.forwardPort(80, 10080)
vconfig.forwardPort(443, 10443)

# add default chef solo stuff, recipes will be added in the custom config file 
vconfig.addCookbookPath(File.expand_path(File.join(File.dirname(__FILE__),"..","cookbooks")))
