class FixLicensorInMangas < ActiveRecord::Migration[5.2]
  def change
    Manga.where(licensor: 'Alt Graph ').update_all licensor: 'Alt Graph'
    Manga.where(licensor: 'Фабрика комиксов ').update_all licensor: 'Фабрика комиксов'
  end
end
