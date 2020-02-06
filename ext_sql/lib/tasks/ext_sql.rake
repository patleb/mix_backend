require_rel 'ext_sql'

namespace :db do
  namespace :pg do
    %w(dump restore truncate).each do |name|
      desc "-- [options] #{name.humanize}"
      task name.to_sym => :environment do |t|
        "::Db::Pg::#{name.camelize}".constantize.new(self, t).run!
      end
    end

    desc 'Drop all'
    task :drop_all => :environment do
      sh Sh.psql 'DROP OWNED BY CURRENT_USER', ExtRake.config.db_url
    end

    # https://www.dbrnd.com/2018/04/postgresql-9-5-brin-index-maintenance-using-brin_summarize_new_values-add-new-data-page-in-brin-index/
    # https://www.postgresql.org/docs/11/brin-intro.html
    # https://www.postgresql.org/docs/10/functions-admin.html
    desc 'BRIN summarize'
    task :brin_summarize, [:index] => :environment do |t, args|
      sh Sh.psql "SELECT brin_summarize_new_values('#{args[:index]}')", ExtRake.config.db_url
    end

    desc 'ANALYZE database'
    task :analyze, [:table] => :environment do |t, args|
      sh Sh.psql "ANALYZE VERBOSE #{args[:table]}", ExtRake.config.db_url
    end

    desc 'VACUUM database'
    task :vacuum, [:table, :analyze, :full] => :environment do |t, args|
      analyze = 'ANALYZE' if flag_on? args, :analyze
      full = 'FULL' if flag_on? args, :full
      sh Sh.psql "VACUUM #{full} #{analyze} VERBOSE #{args[:table]}", ExtRake.config.db_url
    end
  end
end
