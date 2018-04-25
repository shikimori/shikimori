# compine shikimori & mal_graph banned couplings
=begin
def cleanup
  ignored_mal_coupling = %w[A18429 A6115]
  loader = { 'A' => Anime, 'M' => Manga }
  shiki_data = YAML.load_file(Animes::BannedRelations::CONFIG_PATH)
  mal_data = JSON.
    parse(open('https://raw.githubusercontent.com/anime-plus/graph/master/data/banned-franchise-coupling.json').read).
    map { |k,v| ([k] + v) }.
    reject { |group| (group & ignored_mal_coupling).any? };

  combined_data = (shiki_data + mal_data).map(&:sort).sort.uniq.map do |ids|
    ids.map do |id|
      "#{id[0]}#{id[/\d+/]}###" + loader[id[0]].find(id[/\d+/]).name[0..60]
    end
  end;

  File.open(Animes::BannedRelations::CONFIG_PATH, 'w') do |v|
    v.write(
      combined_data.
        to_yaml.
        gsub(/^- -/, "-\n  -").
        gsub('###', ' # ').
        gsub("'", '')
    )
  end;
  %x{touch tmp/restart.txt && bundle exec rails r 'Rails.cache.clear'}
  ap combined_data
end
cleanup
=end

class Animes::BannedRelations
  include Singleton

  CONFIG_PATH = "#{Rails.root}/config/app/banned_franchise_coupling.yml"

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
          memo[:animes] << group.map { |v| v.sub(/^A|-.*$/, '').to_i }
        else
          memo[:mangas] << group.map { |v| v.sub(/^M|-.*$/, '').to_i }
        end
      end
  end

  def banned_couplings_data
    YAML.load_file CONFIG_PATH
  end
end
