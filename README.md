# Vagrant Common

A base set of Chef recipes and preset Vagrant values that I can use as a common base for any
projects that uses Vagrant for the dev environment

## My problem

I was copy/pasting the same `vagrantfile` into all my projects, and when I found a bug or changed
a setting in one `vagrantfile` I had to copy the change and go into all the other projects and 
paste the change into their respective vagrantfiles.

## My solution

A global common `Vagrantfile` that had a bunch of common settings and Chef recipes that I could
import into any other project as a Git submodule that I could then use as a base which could of course be
overridden in a local project specific `Vagrantfile`

The lib/Vagrant.rb file allows you to set Vagrant configuration options using a singleton
class that you can access in as many child vagrantfiles as you want.

## Getting started

Copy one of the sample Vagrantfiles into your base directory and rename to Vagrantfile.

For example, if you were going to create a vagrant box to do php development, you would do:

    $ cd path/to/this/repository
    $ cp ./Vagrantfile.php.sample path/to/project/Vagrantfile

then open `path/to/project/Vagrantfile` and edit the top require line to include the correct path to

> lib/VagrantfileCommon

and then edit the new `path/to/project/Vagrantfile` to customize your project's configuration.
Then you should just be able to run:

    vagrant up

And have a working base box.

## Things to know

### the included recipes are only useful if you want to use Ubuntu

That's what I use, that's what I write the recipes for, I'm not going for ultimate portability.

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
