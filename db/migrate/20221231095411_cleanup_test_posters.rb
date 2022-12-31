class CleanupTestPosters < ActiveRecord::Migration[6.1]
  def up
    [Anime, Manga, Character, Person].each do |klass|
      klass.where("desynced && '{poster}'").includes(:posters).find_each do |entry|
        entry.desynced -= %w[poster]
        entry.save!
        entry.posters.each(&:destroy!)
      end

      klass.where("desynced && '{image}'").includes(:posters).find_each do |entry|
      end
    end
    Versions::PosterVersion.destroy_all
    Poster.where.not(deleted_at: nil).destroy_all
  end
end
