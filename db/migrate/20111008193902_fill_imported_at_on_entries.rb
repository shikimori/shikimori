class FillImportedAtOnEntries < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update animes set imported_at = now()")
    ActiveRecord::Base.connection.execute("update mangas set imported_at = now()")
    ActiveRecord::Base.connection.execute("update characters set imported_at = now()")
    ActiveRecord::Base.connection.execute("update people set imported_at = now()")
  end

  def self.down
  end
end
