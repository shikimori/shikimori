class FillEnglishNewAndJapaneseNewFieldsInMangas < ActiveRecord::Migration
  def change
    count = Manga.count
    Manga.all.each_with_index do |entry, index|
      puts "#{index} / #{count}"
      entry.update(
        english_new: entry.english.first,
        japanese_new: entry.japanese.first
      )
    end
  end
end
