class Animes::UpdateFranchises
  method_object

  def initialize
    @processed_ids = { Anime => [], Manga => [], Ranobe => [] }
    @franchises = []
  end

  def call
    process Anime.order(:id), processed_ids
    process Manga.order(:id), processed_ids
  end

private

  def process scope, processed_ids
    scope.find_each do |entry|
      next if processed_ids[entry.class].include? entry.id

      chronology = Animes::ChronologyQuery.new(entry).fetch

      if chronology.many?

      else
        processed_ids[entry.class] << entry.id
        entry.update franchise: nil
      end
    end
  end

  def animes_scope
    Anime.order(:id)
  end
end
