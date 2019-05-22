case "$OS" in
ubuntu)
  RUBY_VERSION="<%= @sun.ruby || "$(sun.current_version 'ruby-full')" %>"
  RUBY_MANIFEST=$(sun.manifest_path 'ruby-full')

  if [[ ! -s "$RUBY_MANIFEST" ]]; then
    sun.install "ruby-full=$RUBY_VERSION"
    apt-mark hold ruby-full

    echo 'gem: --no-document' > $HOME/.gemrc

    if sun.version_is_smaller "$RUBY_VERSION" "2.6"; then
      gem install bundler
    fi
  else
    sun.update

    declare -a gem_names=($(gem list | cut -d ' ' -f 1))
    declare -a gem_versions=($(gem list | cut -d ' ' -f 2 | sed -r 's/(^\(|\)$|,$)//g'))

    apt-mark unhold ruby-full
    sun.install "ruby-full=$RUBY_VERSION"
    apt-mark hold ruby-full

    for i in "${!gem_names[@]}"; do
      gem install "${gem_names[$i]}" -v "${gem_versions[$i]}" --ignore-dependencies
    done
  fi

  echo "$RUBY_VERSION" >> "$RUBY_MANIFEST"
;;
centos)
  sun.install "ruby-devel"
  echo 'gem: --no-document' > $HOME/.gemrc
  echo 'gem: --no-document' > ~/.gemrc
  gem install bundler -v=1.17.3
;;
esac
