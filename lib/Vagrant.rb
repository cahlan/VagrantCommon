##
# I created this to allow multiple vagrant files to share similar configuration
# 
# basically, I wanted stuff like nfs folder options to exist through multiple files and
# have default values be set before a user has a chance to set up configuration. And,
# I wanted to be able to package this up and easily create a base box without having to
# configure much of anything
# 
# tested on Vagrant 0.9.4
# 
# vagrant documentation: http://vagrantup.com/docs/vagrantfile.html
#
# @example
#   config = Vagrant.configuration.get #get the singleton configuration from any Vagrantfile
# 
# @author Jay Marcyes
##
require 'vagrant/util/platform'

module Vagrant extend self

  class Configuration

    # needed to make sure all methods can be called like this: Module.method outside
    # http://stackoverflow.com/questions/2353498/is-extend-self-the-same-as-module-function
    # http://www.ruby-doc.org/docs/ProgrammingRuby/html/ref_c_module.html#Module.module_function
    # module_function
  
    ##
    # holds all the vagrant box configurations
    #
    # @var  hash  the key is the box name, the value is a Vagrant::BoxConfiguration instance
    ##
    attr_accessor :box_configs
    
    ##
    # holds the directory containing the vagrantfile
    #
    # @since  2-25-12
    # @var  string
    ##
    attr_accessor :vagrant_root
    
    ##
    # holds the user's ssh public key
    #
    # @since  2-25-12
    # @var  hash
    ##
    attr_accessor :user_ssh_keys
    
    ##
    # get a BoxConfiguration singleton so you can customize its configuration 
    #
    # @since  2-25-12
    # @param  symbol  box the name of the vagrant box you want to configure
    # @return Vagrant::BoxConfiguration
    ##
    def self.get(box = :main)
    
      @box_configs ||= {}
      
      if @box_configs.empty?
      
        # this configure block will do all the heavy lifting once this class is completely populated, 
        # the block will be ran by Vagrant after all the vagrant files have been loaded
        ::Vagrant::Config.run do |config|
          
          # go through each of the custom box configurations in this class
          @box_configs.each_key do |box|
            
            # each box configuration gets its own custom Vagrant configuration
            # http://vagrantup.com/docs/multivm.html
            config.vm.define box do |box_config|
              
              box_config.vm.customize @box_configs[box].customizations
              
              # handle bridged networking
              # http://vagrantup.com/docs/bridged_networking.html
              if @box_configs[box].config_field_map.has_key?('network')
              
                if @box_configs[box].config_field_map['network'].include?(:bridged)
                
                  @box_configs[box].addRecipe("network::bridged")
                
                end
              
              end
              
              setConfigFields(box_config,@box_configs[box])
              setChefFields(box_config,@box_configs[box])
              
            end
            
          end
          
        end
      
      end
      
      # create the box config and set defaults
      if !@box_configs.has_key?(box)
      
        @box_configs[box] = Vagrant::BoxConfiguration.new

        @box_configs[box].shareFolder("v-root","/vagrant",findVagrantRoot())
        
        if ssh_keys = getUserSSHKeys()
          
          @box_configs[box].addRecipe("ssh-keys",ssh_keys)
        
        end
        
      end
      
      @box_configs[box]
    
    end
    
    private
    
    ##
    # add the user's ssh public/private keys to the vagrant box's authorized_keys and other ssh files
    #     
    # @since  2-25-12
    # @return string
    ##
    def self.getUserSSHKeys()
    
      # canary
      return @user_ssh_keys if !@user_ssh_keys.nil?
    
      # add the host machine user's ssh key to the vagrant user authorized_keys file
      if(ENV.key?("HOME"))
      
        ssh_paths = {
          :public_keys => File.join(ENV["HOME"],".ssh","id_rsa.pub"),
          :rsa_key => File.join(ENV["HOME"],".ssh","id_rsa"),
          :dsa_key => File.join(ENV["HOME"],".ssh","id_dsa")
        }
      
        ssh_paths.each do |k,p|
        
          if(File.exists?(p))
        
            @user_ssh_keys ||= {}
            @user_ssh_keys[k] = File.open(p,"r").read
            
          end
        
        end
      
      end
    
      @user_ssh_keys
    
    end
    
    ##
    # sometimes vagrant is called from a subdirectory, this will find the root dir
    #     
    # the root dir is defined as the directory that contains the vagrantfile
    # 
    # @since  2-25-12
    # @return string  the path to the root directory
    ##
    def self.findVagrantRoot()
    
      # canary
      return @vagrant_root if !@vagrant_root.nil?
    
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
      
      @vagrant_root = vroot
    
    end
    
    ##
    # actually pass the config fields that were set in this class to the vagrant config
    #
    # @param  Config::Top config  the configuration object
    # @param  Vagrant::BoxConfiguration the custom box configuration
    ##
    def self.setConfigFields(config,box_configuration)
    
      # load all the previously set configuration variables
      box_configuration.config_field_map.each do |t,config_keys|
      
        vconfig = config.method_missing(t.to_sym())
        
        # add all the fields to the found configuration class
        config_keys.each do |k,v|
          configureField(vconfig,k,v)
        end
          
        # configureField(config.vm,k,v)
      
      end
    
    end
    
    ##
    # actually pass the chef fields that were set in this class to the vagrant config
    #
    # @param  Config::Top config  the configuration object
    # @param  Vagrant::BoxConfiguration the custom box configuration
    ##
    def self.setChefFields(config,box_configuration)
    
      # canary
      return if box_configuration.chef_recipe_map.empty?
      
      # this block is run by Vagrant after all Vagrantfiles are loaded
      config.vm.provision :chef_solo do |chef|
      
        # https://github.com/mitchellh/vagrant/pull/303
        # http://kief.com/node/76
        chef.log_level = :debug
        
        box_configuration.chef_field_map.each do |k,v|
          
          configureField(chef,k,v)
        
        end
        
        box_configuration.chef_recipe_map.each do |recipe,json|
          
          chef.json.merge!(json)
          chef.add_recipe(recipe)
        
        end
        
      end
        
    end
    
    ##
    # this is the common method that will set the k field of obj with the value v
    #
    # @param  object  obj the object whose field will be set
    # @param  string  k the field
    # @param  string  v the field k's value
    ##
    def self.configureField(obj,k,v)
    
      # http://www.khelll.com/blog/ruby/ruby-dynamic-method-calling/
      # if k = "foo" then this would check for a method name like: foo= (the = is ruby syntax for set) 
      method_name = "#{k}="
      
      if obj.respond_to?(method_name)
      
        # we set each value in the array using the set method k
        # if k = "foo" and v = [[1, 2], 3] we would call foo=([1,2]) and foo=(3)
        v.each do |val| obj.send(method_name,val) end
        
      else
      
        # we will call method k with each value in the array
        # basically, if k = "foo" and v = [[1, 2], 3] this would be the same as calling foo(1,2) and foo(3)
      
        # http://stackoverflow.com/questions/5119352/achieving-call-user-func-array-in-ruby
        v.each do |val| obj.send(k,*val) end
      
      end
      
      # print "#{k} = #{v}\r\n"
    
    end
    
  end

  class BoxConfiguration

    # needed to make sure all methods can be called like this: Module.method outside
    # http://stackoverflow.com/questions/2353498/is-extend-self-the-same-as-module-function
    # http://www.ruby-doc.org/docs/ProgrammingRuby/html/ref_c_module.html#Module.module_function
    # module_function
  
    ##
    # set to true or false if nfs is needed to make shared folders work
    #
    # @link http://vagrantup.com/docs/nfs.html
    # @var  boolean
    ##
    attr_accessor :nfs_on
    
    ##
    # hold the vagrant vm customize fields
    #
    # @var  array
    # @since  2-5-12
    ##
    attr_accessor :customizations
    
    ##
    # will hold the configuration fields that will be passed to the vagrant configs
    #
    # @var  hash
    ##
    attr_accessor :config_field_map
    
    ##
    # holds the chef fields that will be set if a chef recipe is added
    #
    # @var  hash
    ##
    attr_accessor :chef_field_map
    
    ##
    # hold the chef recipes
    #
    # @var  hash
    ##
    attr_accessor :chef_recipe_map
    
    def initialize()
      
      @nfs_on = nil
      @config_field_map = {}
      @chef_field_map = {}
      @chef_recipe_map = {}
      @customizations = []
      
    end

    ##    
    # Set the amount of RAM the Virtual machine will use 
    #
    # @since  2-22-12
    # @param  integer n the amount of RAM you want to dedicate to the vagrant box
    ##
    def setMemory(n)
    
      customize("memory",n)
    
    end

    ##    
    # Set the name of the Virtual machine
    #     
    # this is handy because "project name" looks better than the "folder_timestamp" generated name 
    #
    # @since  2-5-12
    # @param  string  n the name you want the vagrant box to have
    ##
    def setName(n)
    
      customize("name",n)
    
    end
    
    ##
    # add a customization to the virtualmachine
    # 
    # in the background, these are commands that will be used to call VBoxManage
    # 
    # @since  2-5-12
    ##
    def customize(k,v)
    
      @customizations ||= []
    
      if @customizations.empty?
      
        @customizations << "modifyvm"
        @customizations << :id
    
      end
      
      @customizations << "--#{k}"
      @customizations << String(v)
    
    end
    
    ##
    # set the external ip address, this is so other boxes can communicate with this box
    #
    # connect from one machine to the other using this: ssh vagrant@<ip>
    #
    # @link http://vagrantup.com/docs/host_only_networking.html
    # @since  2-25-12
    # @param  string  ip  something like "33.33.33.10"
    ##
    def setIP(ip)
    
      setField("network",[:hostonly,ip])
    
    end
    
    ##
    # set a configuration field
    #
    # @param  string  k the field
    # @param  mixed v the k value
    # @param  string t the field type, (eg, vm, ssh)
    ##
    def setField(k,v,t = "vm")
    
      @config_field_map[t] ||= {}
      @config_field_map[t][k] ||= []
      @config_field_map[t][k] << v
    
    end
    
    ##
    # forward a port
    #
    # @param  integer vm_port the port you want to forward on the vm (eg, 80, or 443)
    # @param  integer main_port the port the vm_port will map to this port (eg, 8080)
    ##
    def forwardPort(vm_port,main_port)
    
      setField("forward_port",[vm_port,main_port,:auto => true])
    
    end
    
    ##
    # forward a port
    #
    # @since  1-26-12
    # @param  string  box_name  the name of the box you want to use
    # @param  string  box_url the url where the box can be remotely fetched if not available locally
    ##
    def setBox(box_name,box_url = "")
    
      setField("box",box_name)
      setField("box_url",box_url)
    
    end
    
    ##
    # share a folder with the vm box
    #
    # @param  string  label the name you want to give to this port forwarding
    # @param  string  vm_path the path the folder will have on the vm box
    # @param  string  main_path the path the folder will have on the host machine
    # @param  hash  options any options you want to set
    ##
    def shareFolder(label,vm_path,main_path,options = {})
      
      if @nfs_on.nil?
      
        # Switching to nfs for only those who can use it
        # thanks http://www.jedi.be/blog/2011/03/28/using-vagrant-as-a-team/
        # http://vagrantup.com/docs/nfs.html
        @nfs_on = !::Vagrant::Util::Platform.windows?
        # @nfs_on = RUBY_PLATFORM.include?('darwin')
        # http://www.ruby-forum.com/topic/86488
        # mac: puts RUBY_PLATFORM => i686-darwin10
        # windows: puts RUBY_PLATFORM => i386-mingw32
      
      end
      
      # do this every time a folder is shared and nfs is on
      if(@nfs_on)
      
        options.merge({:nfs => true})
      
      end
      
      setField("share_folder",[label,vm_path,main_path,options])
    
    end
    
    ##
    # set a chef field
    #
    # @param  string  k the field
    # @param  mixed v the k value
    ##
    def setChefField(k,v)
    
      # initialize an empty list
      # we need to have an array inside an array so configure field will work
      # eg, we need [[]]
      @chef_field_map[k] ||= []
      @chef_field_map[k][0] ||= []
      @chef_field_map[k][0] << v
    
    end
    
    ##
    # add a chef solo cookbook path
    #
    # @param  string  cookbook_path the local machine path
    ##
    def addCookbookPath(cookbook_path)
  
      # canary
      raise ArgumentError, 'cookbook_path does not exist' unless File.directory?(cookbook_path)
      
      setChefField("cookbooks_path",cookbook_path)
    
    end
    
    ##
    # add a chef recipe
    #
    # @param  string  recipe  the name of the recipe
    # @param  hash  json  any custom configuration you want to pass to the recipe
    ##
    def addRecipe(recipe,json = {})
    
      if !json.empty?
      
        # normalize the json (get rid of the ::namespaces of the recipes and turn dashes into underscore...
        recipe_json_name = recipe.gsub(/\:+.+$/,"").gsub("-","_")
      
        if !json.has_key?(recipe_json_name.to_sym)
        
          # we want to namespace the json
          json = {
            recipe_json_name.to_sym => json
          }
        
        end
        
      end
    
      @chef_recipe_map[recipe] ||= {}
      @chef_recipe_map[recipe].merge!(json)
    
    end
  
  end
  
end
