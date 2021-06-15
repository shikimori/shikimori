class FixDbEntriesDescriptions < ActiveRecord::Migration[5.2]
  def up
    [Anime, Manga, Character].each do |klass|
      klass
        .where("description_ru like '%[br]%'")
        .find_each do |entry|
          puts "#{klass.name}=#{entry.id}"
          entry.update! description_ru: entry.description_ru.gsub('[br]', "\n").strip
        end
    end
  end
end
