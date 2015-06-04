[![Build Status](https://travis-ci.org/ylosix/ylosix.svg?branch=develop)](https://travis-ci.org/ylosix/ylosix)
[![Dependency Status](https://gemnasium.com/ylosix/ylosix.svg)](https://gemnasium.com/ylosix/ylosix)
[![Coverage Status](https://coveralls.io/repos/ylosix/ylosix/badge.svg?branch=develop)](https://coveralls.io/r/ylosix/ylosix?branch=develop)
[![Code Climate](https://codeclimate.com/github/ylosix/ylosix/badges/gpa.svg)](https://codeclimate.com/github/ylosix/ylosix)
[![Inline docs](http://inch-ci.org/github/ylosix/ylosix.svg?branch=develop)](http://inch-ci.org/github/ylosix/ylosix)
[![security](https://hakiri.io/github/ylosix/ylosix/develop.svg)](https://hakiri.io/github/ylosix/ylosix)

## REAME

Open source ecommerce.

  * Ruby version: 2.1.6
  
  * Rails version: 4.2.1
  
  * Puppet: 3.7.5
  
  * [Installation](#installation)
  
  * Configuration
  
  * [Design schema](#design-schema)
  
  * [Database creation](#database-creation)
  
  * [How to run the test suite](#testing)
  
  * [The ecommerce](#the-ecommerce)
  
  * Services (job queues, cache servers, search engines, etc.)
  
  * [Deployment instructions](#deployment-instructions)


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.


## Installation

Install git and after clone the repository(be careful with submodules):

```
$ git clone --recursive https://github.com/devcows/ecommerce.git
```

To install Vagrant download [Vagrant](https://www.vagrantup.com) and install it. Install Vagrant plugin triggers, open a console and type:

```
$ vagrant plugin install vagrant-triggers
```

After open a console in project path:

```
$ vagrant up main_app
```

The first time Vagrant takes more time and prepare the virtual machine. The next runs Vagrant goes more quickly.

After vagrant up, you already have a develop environment, the application is running at: <br />
[http://localhost:13000](http://localhost:13000)

Troubleshooting gem nokoguiri in Mac os x (Yosemite):
```
$ port install libiconv libxslt libxml2
$ gem install nokogiri -- --use-system-libraries --with-iconv-dir=/opt/local --with-xml2-dir=/opt/local --with-xslt-dir=/opt/local
```

Troubleshooting git clone in windows:
  - Windows by default use crlf true and adds \r in every \n. The puppet recipe fails with \r. 
```
git config --global core.autocrlf false
```

Build and run with docker:
```
# build your dockerfile
$ docker build -t ryanfox1985/ecommerce .

# run container
$ docker run -d -p 80:80 -e SECRET_KEY_BASE=secretkey ryanfox1985/ecommerce

# run console
docker run -i -t ryanfox1985/ecommerce:latest /bin/bash
```

## Design schema

![Alt text](https://raw.githubusercontent.com/devcows/ecommerce/develop/erd.png "Design")


## Database creation

```
$ rake db:create
$ rake db:migrate
$ rake db:seed
```

## Testing

To run the test suite execute:

```
$ rake
```

## The ecommerce

Default Postgresql config: <br />
  - Port: 15432 <br />
  - Database: ecommerce <br />
  - User: ecommerce_user <br />
  - Password: ecommerce_pass <br />

The main web application is running at: <br />
[http://localhost:13000](http://localhost:13000)

The default customer user is {:email => 'user@example.com', :password => 'password' }.

The application backoffice is running at: <br />
[http://localhost:13000/admin](http://localhost:13000/admin)

The default admin user is {:email => 'admin@example.com', :password => 'password' }.

Demo at: <br />
[Link to heroku](http://devcows-ecommerce.herokuapp.com)

## Deployment instructions

__With heroku:__
  - Register at [heroku](https://www.heroku.com)

```
$ git clone --recursive https://github.com/devcows/ecommerce.git
$ cd ecommerce
$ heroku login
$ heroku create
$ heroku addons:add heroku-postgresql:hobby-dev
$ heroku config:set RAILS_DB=postgresql
$ git push heroku develop:master

$ heroku run rake db:migrate RAILS_ENV=production
$ heroku run rake db:seed
```

__With digital ocean:__
```
$ vagrant plugin install vagrant-digitalocean
```

  - Generate API token:
    https://cloud.digitalocean.com/settings/applications

  - Add token code in Vagrant file at YOUR_TOKEN:
```
  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'

    provider.token = 'YOUR_TOKEN'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'nyc2'
    provider.size = '512mb'
  end
```

  - Execute:
```
$ git clone --recursive https://github.com/devcows/ecommerce.git
$ cd ecommerce
$ RAILS_ENV=production vagrant up main_app --provider=digital_ocean
```

__With a managed server:__

  - Add server ssh config:
```
  app.vm.provider :managed do |provider, override|
    override.ssh.username = 'username'
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'tknerr/managed-server-dummy'

    provider.server = 'example.com'
  end  
```

  - Execute:
```
$ vagrant plugin install vagrant-managed-servers
$ git clone --recursive https://github.com/devcows/ecommerce.git
$ cd ecommerce
$ RAILS_ENV=production vagrant up main_app --provider=managed
$ RAILS_ENV=production vagrant provision main_app
```

  - Troubleshooting Puppet old version:
    https://docs.puppetlabs.com/guides/install_puppet/install_debian_ubuntu.html