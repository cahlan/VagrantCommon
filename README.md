## What does this do?

I wanted a way to create a global `Vagrantfile` that had a bunch of predifined settings
that I could then use as a base and override in a local project specific `Vagrantfile` so
the lib/Vagrant.rb file allows you to set Vagrant configuration options using a singleton
class that you can get access to in as many vagrant files as you want.

## Getting started

Copy Vagrantfile.sample into your base directory and rename to Vagrantfile

    $ cd path/to/your/project
    $ cp ./Vagrantfile.sample path/to/your/project/Vagrantfile

then open `path/to/your/project/Vagrantfile` and edit the top require line to include the correct path to

> list/VagrantfileCommon

and then edit your Vagrantfile to customize your project's configuration. Then you should be able to just do

    vagrant up

And have a working base box.

## Things to know

### the included recipes are only useful if you want to use Ubuntu

That's what I use, that's what I write the recipes for, I'm not going for ultimate portability

### Take a look at the `lib/Vagrant.rb` methods to learn how to set up your environment

It's pretty well documented with hopefully easy to understand method names, the `lib/VagrantfileCommon`
and `Vagrantfile.sample` files should also point you in the right direction about how to use
the Singleton configuration object.

### Debugging

If you want to see what Vagrant is doing, you can set [debugging](https://github.com/mitchellh/vagrant/issues/645)
before starting

On Windows

     set VAGRANT_LOG=debug
     vagrant up

on Linux

    export VAGRANT_LOG=debug
    vagrant up
