Copy Vagrantfile.sample into the app directory

    $ cd path/to/app/directory
    $ cp ./plugins/Vagrant/config/Vagrantfile.sample ./Vagrantfile

Then you should be able to just do

    $ vagrant up

And have a working base box with nginx, php, and phpunit ready to go