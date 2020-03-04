module Db
  module Pg
    class Base < ActiveTask::Base
      include ExtRake::Pg::Psql
      include ExtRake::Pg::Rescuable

      def self.pg_options
        ENV['PG_OPTIONS']
      end

      protected

      def with_db_config
        db = ExtRake.config.db_config
        yield db[:host],
          db[:database],
          db[:username],
          db[:password]
      end

      def pg_data_dir
        @pg_data_dir ||= Pathname.new(`sudo cat /home/$(id -nu 1000)/sun_metadata/pg_data_dir`.strip)
      end

      def su_postgres(cmd)
        <<-CMD.squish
          cd /tmp && sudo su postgres -c 'set -e; #{cmd}'
        CMD
      end
    end
  end
end
