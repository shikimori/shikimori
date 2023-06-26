class Animes::BannedRelations
  include Singleton

  CONFIG_PATH = Rails.root.join('config/app/banned_franchise_coupling.yml')
  ANIME_ID_CLENAUP_REGEXP = /^A|-.*$/
  MANGA_ID_CLENAUP_REGEXP = /^M|-.*$/
  ANYTHING = '*'

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
        next if id == ANYTHING

        memo[id] ||= []
        memo[id].concat(ids.reject { |v| v == id })
      end
    end
  end

  def cache
    {
      animes: banned_franchise_coupling[:animes],
      mangas: banned_franchise_coupling[:mangas]
    }
  end

  def banned_franchise_coupling
    @banned_franchise_coupling ||= banned_couplings_data
      .each_with_object(animes: [], mangas: []) do |group, memo|
        if group.first.starts_with? 'A'
          memo[:animes] << group.map { |id| parse_id id, ANIME_ID_CLENAUP_REGEXP }
        else
          memo[:mangas] << group.map { |id| parse_id id, MANGA_ID_CLENAUP_REGEXP }
        end
      end
  end

  def banned_couplings_data
    @banned_couplings_data ||= YAML.load_file CONFIG_PATH
  end

  def parse_id id, cleanup_regexp
    return id if id == ANYTHING

    id.sub(cleanup_regexp, '').to_i
  end
end
