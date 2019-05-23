DEPLOYER_NAME=<%= @sun.deployer_name %>

case "$OS" in
ubuntu)
  sun.install "libjemalloc-dev"
;;
centos)
  sun.install "jemalloc jemalloc-devel"
;;
esac

sudo su - $DEPLOYER_NAME << 'EOF'
  DEPLOYER_NAME=<%= @sun.deployer_name %>
  PLUGINS_PATH=/home/$DEPLOYER_NAME/.rbenv/plugins
  PROFILE=/home/$DEPLOYER_NAME/.bashrc
  RUBY_VERSION=<%= @sun.rbenv_ruby %>
  RBENV_OPTIONS='--with-jemalloc --enable-shared --disable-install-doc --disable-install-rdoc --disable-install-capi'

  if [[ ! -s "/home/$DEPLOYER_NAME/.rbenv" ]]; then
    git clone git://github.com/sstephenson/rbenv.git /home/$DEPLOYER_NAME/.rbenv
    git clone git://github.com/sstephenson/ruby-build.git $PLUGINS_PATH/ruby-build
    git clone git://github.com/sstephenson/rbenv-gem-rehash.git $PLUGINS_PATH/rbenv-gem-rehash
    git clone git://github.com/dcarley/rbenv-sudo.git $PLUGINS_PATH/rbenv-sudo

    echo '<%= Sh.rbenv_export(@sun.deployer_name) %>' >> $PROFILE
    echo '<%= Sh.rbenv_init %>' >> $PROFILE
    echo 'gem: --no-document' > /home/$DEPLOYER_NAME/.gemrc
  else
    cd /home/$DEPLOYER_NAME/.rbenv && git pull
    cd $PLUGINS_PATH/ruby-build && git pull
    cd $PLUGINS_PATH/rbenv-gem-rehash && git pull
    cd $PLUGINS_PATH/rbenv-sudo && git pull
    cd /home/$DEPLOYER_NAME
  fi

  <%= Sh.rbenv_export(@sun.deployer_name) %>
  <%= Sh.rbenv_init %>

  RUBY_CONFIGURE_OPTS=$RBENV_OPTIONS rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION
  gem install bundler
EOF
