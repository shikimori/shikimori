class FillEnglishNewAndJapaneseNewFieldsInAnimes < ActiveRecord::Migration[5.2]
  def up
    count = Anime.count
    Anime.all.each_with_index do |entry, index|
      puts "#{index} / #{count}"
      entry.update(
        english_new: entry.english.first,
        japanese_new: entry.japanese.first
      )
    end
  end
end
