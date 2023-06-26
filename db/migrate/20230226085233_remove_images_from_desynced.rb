class RemoveImagesFromDesynced < ActiveRecord::Migration[6.1]
  def up
    [Anime, Manga, Character, Person].each do |klass|
      scope = klass.where("'image' = any(desynced)")
      size = scope.count

      scope.each_with_index do |entry, index|
        puts "#{klass.name} #{index + 1} / #{size}"
        entry.desynced -= %w[image]
        entry.save!
      end
    end
  end
end
