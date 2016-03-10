class MigrateJapaneseAnimeVideoLanguageToOriginalLanguage < ActiveRecord::Migration
  def up
    AnimeVideo.where(language: :japanese).update_all language: :original
  end

  def down
    AnimeVideo.where(language: :original).update_all language: :japanese
  end
end
