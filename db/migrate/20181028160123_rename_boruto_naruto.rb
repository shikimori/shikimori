class RenameBorutoNaruto < ActiveRecord::Migration[5.2]
  def up
    Achievement.where(neko_id: 'boruto').update_all neko_id: 'naruto'
    Anime.where(franchise: 'boruto').update_all franchise: 'naruto'
    Manga.where(franchise: 'boruto').update_all franchise: 'naruto'
  end

  def down
    Achievement.where(neko_id: 'naruto').update_all neko_id: 'boruto'
    Anime.where(franchise: 'naruto').update_all franchise: 'boruto'
    Manga.where(franchise: 'naruto').update_all franchise: 'boruto'
  end
end
