class Animes::UpdateFranchises
  method_object

  def initialize
    @processed_ids = { Anime => [], Manga => [], Ranobe => [] }
    @franchises = []
  end

  def call
    process Anime
    process Manga
  end

private

  def process scope
    scope.find_each do |entry|
      next if @processed_ids[entry.class].include? entry.id
      chronology = Animes::ChronologyQuery.new(entry).fetch

      if chronology.many?
        add_franchise chronology
      else
        remove_franchise entry
      end
    end
  end

  def add_franchise entries
    franchise = Animes::FranchiseName.call entries, @franchises

    entries.each do |entry|
      @processed_ids[entry.class] << entry.id
      entry.update franchise: franchise
    end
  end

  def remove_franchise entry
    @processed_ids[entry.class] << entry.id
    entry.update franchise: nil
  end
end
