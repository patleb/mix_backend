# encoding: utf-8

require 'mr_backup/configuration'

Secret.load

root_path MrBackup.config.backup_dir

Logger.configure do
  logfile.enabled = false
end

Storage::Local.defaults do |local|
  local.path = MrBackup.config.backup_local_path
end

Storage::S3.defaults do |s3|
  s3.access_key_id     = MrBackup.config.s3_access_key_id
  s3.secret_access_key = MrBackup.config.s3_secret_access_key
  s3.region            = MrBackup.config.s3_region
  s3.bucket            = MrBackup.config.s3_bucket
  s3.path              = MrBackup.config.backup_s3_path
  s3.storage_class     = :standard_ia
end

Syncer::RSync::Local.defaults do |local|
  local.path   = MrBackup.config.backup_local_path
  local.mirror = true
end

Syncer::Cloud::S3.defaults do |s3|
  s3.access_key_id     = MrBackup.config.s3_access_key_id
  s3.secret_access_key = MrBackup.config.s3_secret_access_key
  s3.region            = MrBackup.config.s3_region
  s3.bucket            = MrBackup.config.s3_bucket
  s3.path              = MrBackup.config.backup_s3_path
  s3.mirror            = true
end

Notifier::Mail.defaults do |mail|
  mail.on_success           = false
  mail.on_warning           = false
  mail.on_failure           = true

  mail.from                 = Secret[:mail_from]
  mail.to                   = Secret[:mail_to]
  mail.address              = Secret[:mail_address]
  mail.port                 = Secret[:mail_port]
  mail.domain               = Secret[:mail_domain]
  mail.user_name            = Secret[:mail_user_name]
  mail.password             = Secret[:mail_password]
  mail.authentication       = "plain"
  mail.encryption           = :starttls
end

Database::PostgreSQL.defaults do |db|
  db_config = ExtRake.config.db_config
  db.name               = db_config[:database]
  db.username           = db_config[:username]
  db.password           = db_config[:password]
  db.host               = db_config[:host]
  db.port               = 5432
  db.additional_options = %(--clean --no-owner --no-acl)
end

preconfigure 'BaseBackup' do
  compress_with Gzip

  notify_by Mail

  split_into_chunks_of 250 # MB
end

preconfigure 'BaseSync' do
  notify_by Mail
end

BaseBackup.new(:app_logs, 'Backup application logs') do
  store_with MrBackup.config.storage

  archive :logs do |archive|
    archive.add MrBackup.config.log_dir
  end
end

BaseBackup.new(:sys_logs, 'Backup system logs') do
  store_with MrBackup.config.storage

  archive :logs do |archive|
    archive.use_sudo
    archive.add '/var/log/'
  end
end

Model.new(:meta, 'Backup meta directory') do
  before do
    unless Dir.exist? MrBackup.config.backup_meta_dir
      FileUtils.mkdir_p MrBackup.config.backup_meta_dir
    end
  end

  sync_with MrBackup.config.syncer do |syncer|
    syncer.mirror = false

    syncer.directories do |directory|
      directory.add MrBackup.config.backup_meta_dir
      directory.exclude /\/(?!#{MrBackup.config.backup_model})\//
    end
  end

  notify_by Mail
end
