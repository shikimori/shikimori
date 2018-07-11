class RenameBigDataCacheIntoPgCache < ActiveRecord::Migration[5.1]
  def change
    rename_table :big_data_caches, :pg_caches
  end
end
