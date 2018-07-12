class AddBinaryToPgCacheData < ActiveRecord::Migration[5.1]
  def up
    add_column :pg_cache_data, :blob, :binary
    change_column :pg_cache_data, :value, :text, null: true
  end

  def down
    remove_column :pg_cache_data, :blob
    change_column :pg_cache_data, :value, :text, null: false
  end
end
