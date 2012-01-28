
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
