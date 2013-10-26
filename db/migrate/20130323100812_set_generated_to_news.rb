class SetGeneratedToNews < ActiveRecord::Migration
  def up
    Entry.update_all generated: false
    AnimeNews.update_all generated: true
    MangaNews.update_all generated: true
  end
end
