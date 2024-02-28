class CleanupFavoritesFromBannedAnimesAndMangas < ActiveRecord::Migration[7.0]
  def up
    [Anime, Manga, Ranobe].each do |klass|
      banned_ids = klass.all.select(&:banned?).pluck(:id)
      puts "Processing #{klass.name}"
      puts "#{banned_ids.size} banned ids"
      scope = Favourite.where(linked_id: banned_ids, linked_type: klass.name)
      puts "found #{scope.size} favorites"
      scope.destroy_all
      puts "cleared"
    end
  end
end
