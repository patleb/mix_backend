sun.pg_restart_force() {
  if ! systemctl restart postgresql; then
    systemctl reset-failed postgresql
    systemctl start postgresql
  fi
}

sun.pg_major_version() {
  local version="$1"
  IFS='.' read -ra version <<< "$version"
  if sun.version_is_smaller "$version" "10"; then
    echo "${version[0]}.$(echo ${version[1]} | sed -r 's/^([0-9]+).*/\1/')"
  else
    echo "$(echo ${version[0]} | sed -r 's/^([0-9]+).*/\1/')"
  fi
}

sun.pg_default_hba_file() {
  case "$OS" in
  ubuntu)
    echo "/etc/postgresql/$__POSTGRES__/main/pg_hba.conf"
  ;;
  centos)
    echo "/var/lib/pgsql/$__POSTGRES__/data/pg_hba.conf"
  ;;
  esac
}

sun.pg_hba_file() {
  sun.psql 'SHOW hba_file'
}

sun.pg_default_config_file() {
  case "$OS" in
  ubuntu)
    echo "/etc/postgresql/$__POSTGRES__/main/postgresql.conf"
  ;;
  centos)
    echo "/var/lib/pgsql/$__POSTGRES__/data/postgresql.conf"
  ;;
  esac
}

sun.pg_config_file() {
  sun.psql 'SHOW config_file'
}

sun.pg_default_data_dir() {
  case "$OS" in
  ubuntu)
    echo "/var/lib/postgresql/$__POSTGRES__/main"
  ;;
  centos)
    echo "/var/lib/pgsql/$__POSTGRES__/data"
  ;;
  esac
}

sun.pg_data_dir() {
  sun.psql 'SHOW data_directory'
}

sun.pg_default_url() {
  echo "postgresql://$__DB_USERNAME__:$__DB_PASSWORD__@$__DB_HOST__:5432/$__DB_DATABASE__"
}

sun.psql() {
  local cmd="$1"
  case "$#" in
  1)
    sudo su - postgres << EOF | head -n1
      psql -d postgres -tAc "$cmd"
EOF
  ;;
  2|3)
    psql -qtAb -c "$cmd" ${@:2}
  ;;
  *)
    echo "sun.psql: invalid number of arguments (1 <= args <= 3)"
    exit 1
  ;;
  esac
}
