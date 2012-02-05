##
# update Virtual box guest additions on the gues os to match installed virtualbox version 
#
# you can get the version in windows by running the command: 
#   $ "ENV["ProgramFiles"]\Oracle\VirtualBox\VBoxHeadless.exe" --version
# 
# might be able to use the environment variable VBOX_INSTALL_PATH on all platforms
#
# now I just need to figure out how to do it in linux and mac and then update this to automatically
# find the version and update, so vbox_version doesn't need to be updated
##

# find out the latest version of Virtualbox
# the only problem with this is what if the host computer isn't running the latest version
# http://travisonrails.com/2007/11/07/http-get-and-post-requests-with-ruby
# http://stackoverflow.com/questions/4581075/how-make-a-http-get-request-using-ruby-on-rails
# require 'net/http'
# url = URI.parse('http://download.virtualbox.org/virtualbox/LATEST.TXT')
# result = Net::HTTP.get(url) # will have a \n that needs to be trimmed

vbox_name = "VBoxGuestAdditions"
vbox_version = "4.1.6"
vbox_url = "http://download.virtualbox.org/virtualbox/#{vbox_version}/#{vbox_name}_#{vbox_version}.iso"
vbox_path = "/home/vagrant/#{vbox_name}_#{vbox_version}.iso"
vbox_test = "test -d /opt/#{vbox_name}-#{vbox_version}"

case node[:platform]
  
  when "debian", "ubuntu"
    
    execute "downloading guest additions" do
      user "root"
      command "wget #{vbox_url} --output-document=#{vbox_path}"
      not_if vbox_test
      action :run
    end
    
    execute "mounting guest additions" do
      user "root"
      command "mount -o loop #{vbox_path} /mnt"
      not_if vbox_test
      action :run
    end
    
    execute "updating guest additions" do
      user "root"
      command "/mnt/VBoxLinuxAdditions.run"
      not_if vbox_test
      action :run
    end
    
    execute "unmounting guest additions" do
      user "root"
      command "umount /mnt"
      ignore_failure true
      not_if "test ! -d /mnt"
      action :run
    end
    
end
