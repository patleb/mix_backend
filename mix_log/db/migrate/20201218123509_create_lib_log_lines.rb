class CreateLibLogLines < ActiveRecord::Migration[6.0]
  def change
    create_table :lib_log_lines, id: false do |t|
      t.datetime   :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer    :type,       null: false
      t.belongs_to :log,        null: false, index: false, foreign_key: { to_table: :lib_logs }
      t.belongs_to :log_label,  index: false, foreign_key: { to_table: :lib_log_labels }
      t.jsonb      :json_data,  null: false, default: {}
    end

    add_index :lib_log_lines, [:created_at, :type, :log_id, :log_label_id, :json_data], using: :gin,
      name: 'index_lib_log_lines_on_columns'
  end
end
