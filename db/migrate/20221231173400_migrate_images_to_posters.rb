class MigrateImagesToPosters < ActiveRecord::Migration[6.1]
  def change
    [Anime, Manga, Character, Person].each do |klass|
      klass
        .where.not("desynced && '{poster}'")
        .includes(:poster) do |entry|
          next if entry.poster.present?


        end
  end
end
