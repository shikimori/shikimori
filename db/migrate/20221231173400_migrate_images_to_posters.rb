class MigrateImagesToPosters < ActiveRecord::Migration[6.1]
  def up
    return if Rails.env.test?

    [Anime, Manga, Character, Person].each do |klass|
      klass
        .where.not("desynced && '{poster}'")
        .includes(:poster)
        .find_each do |entry|
          next if entry.poster.present?
          next unless entry.image.exists?

          puts "#{klass} #{entry.id}"

          entry.create_poster image: File.open(entry.image.path)
        end
    end
  end
end
