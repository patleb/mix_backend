class CreateLibLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :lib_logs do |t|
      t.belongs_to :server,          null: false, index: false, foreign_key: { to_table: :lib_servers }
      t.string     :path
      t.bigint     :line_i,          null: false, default: 0
      t.datetime   :mtime,           null: false, default: Time.at(0)
      t.integer    :log_lines_type,  null: false
      t.bigint     :log_lines_count, null: false, default: 0
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    add_index :lib_logs, [:server_id, :path, :log_lines_type], unique: true,
      name: 'index_lib_logs_on_server_id_path_log_lines_type', where: 'path IS NOT NULL'
    add_index :lib_logs, [:server_id, :log_lines_type], unique: true,
      name: 'index_lib_logs_on_server_id_log_lines_type', where: 'path IS NULL'

    if Rails.env.test?
      remove_foreign_key :lib_logs, :lib_servers, column: :server_id
    end
  end
end
