#!/bin/bash
APP_PATH=/var/www
RVM_WRAPPERS_PATH=/usr/local/rvm/wrappers/ruby-2.1.0@ecommerce
RVM_SUDO_PATH=/usr/local/rvm/bin/rvmsudo
RAILS_ENV=$1

if [ -z $RAILS_ENV ]; then
  RAILS_ENV=development
fi

#Install nginx
su -c "apt-get install -qq -y nginx --force-yes"
su -c "rm /etc/nginx/sites-enabled/default"

#TODO Check if contains daemon off already.
su -c "echo 'daemon off;' >> /etc/nginx/nginx.conf"
su -c "service nginx stop"
su -c "ln -s '$APP_PATH/puppet/nginx-default.conf' /etc/nginx/conf.d/default.conf"
su -c "ln -s '$APP_PATH/config/unicorn_init.sh' /etc/init.d/unicorn"
su -c "chown -R www-data:www-data /var/log/nginx"
su -c "chmod -R 775 /var/log/nginx"

su -c "adduser vagrant www-data"
su -c "chown www-data:www-data -R $APP_PATH"
su -c "chmod 775 $APP_PATH"
su -c "chmod -R g+w $APP_PATH"


#Create environment
su - vagrant -c "cd $APP_PATH; echo \"2.1.0\" > .ruby-version"
su - vagrant -c "cd $APP_PATH; echo \"ecommerce\" > .ruby-gemset"
su - vagrant -c "cd $APP_PATH; echo $RAILS_ENV > .ruby-env"

if [ -z $SECRET_KEY_BASE ]; then
  su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/rake secret > .ruby-secret"
  SECRET_KEY_BASE=`cat $APP_PATH/.ruby-secret`
fi

database=sqlite
if [ "$RAILS_ENV" == "production" ]; then
  database=postgresql
fi

su - vagrant -c "cd $APP_PATH; echo 'RAILS_ENV=$RAILS_ENV' > .env"
su - vagrant -c "cd $APP_PATH; echo 'SECRET_KEY_BASE=$SECRET_KEY_BASE' >> .env"
su - vagrant -c "cd $APP_PATH; echo 'RAILS_DB=$database' >> .env"
su - vagrant -c "cd $APP_PATH; echo 'DATABASE_URL=postgres://ecommerce_user:ecommerce_pass@localhost:5432/ecommerce' >> .env"

#Setup project
su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/gem install bundler"
su - vagrant -c "cd $APP_PATH; rm .bundle/config"

if [ "$RAILS_ENV" == "production" ]; then
  su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/bundle install --without development test"
else
  su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/bundle install --without production"
  su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/rake db:create RAILS_ENV=$RAILS_ENV"
fi

su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/rake db:migrate RAILS_ENV=$RAILS_ENV"

if [ "$RAILS_ENV" == "production" ]; then
  su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/rake assets:precompile RAILS_ENV=$RAILS_ENV"
fi

su - vagrant -c "cd $APP_PATH; $RVM_WRAPPERS_PATH/rake db:seed RAILS_ENV=$RAILS_ENV"


#Set foreman file
su - vagrant -c "echo 'web: bundle exec unicorn -c config/unicorn.rb -E $RAILS_ENV' > $APP_PATH/Procfile"
su - vagrant -c "echo 'nginx: /usr/sbin/nginx -c /etc/nginx/nginx.conf' >> $APP_PATH/Procfile"

su -c "cd $APP_PATH; $RVM_SUDO_PATH $RVM_WRAPPERS_PATH/bundle exec foreman export upstart --app=ecommerce --user=root /etc/init"
su -c "cd $APP_PATH; $RVM_SUDO_PATH $RVM_WRAPPERS_PATH/bundle exec foreman start -f Procfile &"