class EnableBtreeGin < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'btree_gin'
  end
end
