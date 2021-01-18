class CleanupUrlPgCacheData < ActiveRecord::Migration[5.2]
  def change
    PgCacheData.where("key like 'http%'").delete_all
  end
end
