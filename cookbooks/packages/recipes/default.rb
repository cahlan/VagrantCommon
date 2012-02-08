##
# arbitrarily add packages 
# 
# this is for when you want to add a whole bunch of packages and you don't want to
# create a recipe for each package
#
# @link http://wiki.opscode.com/display/chef/Resources#Resources-Package
# @since  1-31-12 
##

if(node.has_key?(:packages))

  [:install,:upgrade,:remove,:purge].each do |a|
  
    if(node[:packages].has_key?(a))
  
      node[:packages][a].each do |p|
      
        package p do
          action a
        end
        
      end
    
    end
    
  end
    
end
