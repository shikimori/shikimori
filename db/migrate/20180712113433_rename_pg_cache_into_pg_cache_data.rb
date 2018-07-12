class RenamePgCacheIntoPgCacheData < ActiveRecord::Migration[5.1]
  def change
    rename_table :pg_caches, :pg_cache_data
  end
end
