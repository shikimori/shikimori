class MigrateSynonymsToSynonymsNew < ActiveRecord::Migration[5.0]
  def change
    migrate_type Anime
    migrate_type Manga
  end

private

  def migrate_type klass
    count = klass.count

    klass.all.each_with_index do |entry, index|
      puts "#{klass.name} #{index} / #{count}"
      next if entry.synonyms.blank?
      entry.update synonyms_new: entry.synonyms
    end
  end
end
