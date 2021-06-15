class MarkAllDoujinMangasAsCensored < ActiveRecord::Migration[5.2]
  def change
    Manga.where(kind: Types::Manga::Kind[:doujin]).update_all is_censored: true
  end
end
