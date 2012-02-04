##
# arbitrarily add packages 
# 
# this is for when you want to add a whole bunch of packages and you don't want to
# create a recipe for each package
#
# @since  1-31-12 
##

if(!node[:packages].empty?):

  node[:packages].each do |p|

    package p do
      action :upgrade
    end
  
  end

end
