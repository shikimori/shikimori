class FillMalIdToDbEntries < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute('update animes set mal_id = id')
    ActiveRecord::Base.connection.execute('update mangas set mal_id = id')
    ActiveRecord::Base.connection.execute('update characters set mal_id = id')
    ActiveRecord::Base.connection.execute('update people set mal_id = id')
  end
end
