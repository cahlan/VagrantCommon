# http://framework.zend.com/
# http://www.pyrosoft.co.uk/blog/2008/09/02/installing-zend-framework-on-ubuntu-hardy/

package "zend-framework" do
  action :upgrade
end

execute "mv /usr/share/php/libzend-framework-php/Zend /usr/share/php/" do
  user "root"
  action :run
  not_if "test -d /usr/share/php/Zend"
end
