##
# install Python PIP package manager
#
# @link http://www.pip-installer.org/en/latest/requirements.html#freezing-requirements
# @since  1-31-12
##

# need this to get the temp directory using Dir.tmpdir
require "tmpdir"

# to avoid any folders from being created in our repository, or permission errors, 
# just do everything in temp
tmp = Dir.tmpdir

package "python-pip" do
  action :upgrade
end

# update pip
execute "pip install --upgrade pip" do
  cwd tmp
  user "root"
  action :run
  ignore_failure false
end

if(node.has_key?(:pip) && node[:pip].has_key?(:install)):

  node[:pip][:install].each do |p|

    if File.exists?(p) # file? That means it is a requirements file created from pip freeze
    
      execute "pip install -r #{p}" do
        cwd tmp
        user "root"
        action :run
        ignore_failure false
      end
    
    elsif p.match(/(?:git|\S+\+\S+):\/\/\S+/i) # repository url: git:// or repo+http://
    
      # the -e tells pip to keep the code around, we don't care about keeping it around and
      # want the code to be in dist-packages:
      # http://stackoverflow.com/questions/9402035/installing-python-package-from-github-using-pip
      # pip_cmd = p.match("-e") ? "pip install #{p}" : "pip install -e #{p}"
      pip_cmd = "pip install #{p}"
      
      execute pip_cmd do
        cwd tmp
        user "root"
        action :run
        ignore_failure false
      end
    
    elsif p.match(/\S+:\/\/\S+/) # url? an archive that contains a setup.py file
    
      execute "pip install #{p}" do
        cwd tmp
        user "root"
        action :run
        ignore_failure false
      end
    
    else # standard package name
    
      execute "pip install #{p}" do
        cwd tmp
        user "root"
        action :run
        ignore_failure false
      end
    
    end

  end

end

