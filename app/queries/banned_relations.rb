class BannedRelations
  include Singleton

  def anime id
    animes[id] || []
  end

  def manga id
    mangas[id] || []
  end

  def animes
    @animes ||= process_cache :animes
  end

  def mangas
    @mangas ||= process_cache :mangas
  end

  def clear_cache!
    @animes = nil
    @mangas = nil
  end

private
  def process_cache key
    cache[key].each_with_object({}) do |ids, memo|
      ids.each do |id|
        memo[id] ||= []
        memo[id].concat ids.select {|v| v != id }
      end
    end
  end

  # [9627,11737] - сделать пулреквест
  def cache
    {
      animes: [
        [9627,11737],
        [18507,17819],
        [18153,17813],
        [10954,3932,1986,6970,1845],
        [14663,13161,11859]
      ]
    }
  end
end
