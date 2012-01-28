# https://github.com/sebastianbergmann/phpunit

# http://oksoft.antville.org/stories/1981953/
execute "pear upgrade --force PEAR" do
  user "root"
  action :run
  #ignore_failure true
  not_if "which phpunit"
end

execute "pear config-set auto_discover 1" do
  user "root"
  action :run
  ignore_failure true
  not_if "which phpunit"
end

execute "pear install pear.phpunit.de/PHPUnit" do
  user "root"
  action :run
  #ignore_failure false
  not_if "which phpunit"
end
