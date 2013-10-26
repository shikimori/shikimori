class ConvertHistoryImportToMalImport < ActiveRecord::Migration
  def self.up
    UserHistory.where(:action => 'anime_import').update_all(:action => 'mal_anime_import')
    UserHistory.where(:action => 'manga_import').update_all(:action => 'mal_manga_import')
  end

  def self.down
    UserHistory.where(:action => 'mal_anime_import').update_all(:action => 'anime_import')
    UserHistory.where(:action => 'mal_manga_import').update_all(:action => 'manga_import')
  end
end
