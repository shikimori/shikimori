require 'set'

# TODO: вынести Fixes в yml конфиг
class AnimeCalendar < ActiveRecord::Base
  belongs_to :anime

  validates_presence_of :anime
  validates_presence_of :episode
  validates_presence_of :start_at

  Fixes = {
    "danganronpa kibo no gakuen to zetsubo no kokosei the animation" => 16592,
    "ginga kikotai majestic prince" => 15863,
    "kitakubu katsudo kiroku" => 18495,
    "pocket monsters: best wishes! season 2" => 17873,
    "rozen maiden (new)" => 18041,
    "senki zessho symphogear g" => 15793,
    "stella jo-gakuin c3-bu" => 17821,
    "furusato saisei nippon no mukashi banashi" => 13163,
    "hakkenden: toho hakken ibun 2" => 18055,
    "hunter x hunter" => 11061,
    "makai Ōji: devils and realist" => 16890,
    "teekyu 2" => 18121,
    "cho soku henkei gyrozetter" => 14989,
    "gifu dodo!!" => 18771,
    "senyu. dai 2 ki" => 18523,
    "cho jigen game neptune" => 16157,
    "maji de otaku na english! ribbon-chan: eigo de tatakau maho shojo" => 19207,
    "genei o kakeru taiyo" => 17651,
    "kamisama no inai nichiyobi" => 16009,
    "kingdom 2" => 17389,
    "kuromajo-san ga toru!!" => 17653,
    "inu to hasami wa tsukaiyo" => 17831,
    "makai oji: devils and realist" => 16890,
    "battle spirits: sword eyes" => 19877,
    "infinite stratos 2" => 18247,
    "aoki hagane no arpeggio" => 18893,
    "daiya no a" => 18689,
    "kyousogiga" => 19703,
    "phi brain: kami no puzzle 3" => 15651,
    "yozakura quartet ~hana no uta~" => 18497,
    "ore no nonai sentakushi ga" => 19221,
    "aikatsu!" => 20181,
    "kuroko no basuke 2" => 16894,
    "yusha ni narenakatta ore wa shibushibu shushoku o ketsui shimashita." => 18677,
    "diabolik lovers" => 17513,
  }

  EpisodesDiff = {
    'gintama\' enchousen' => 252
  }

  # импорт аниме календаря с animecalendar.net
  def self.parse
    calendar = self.load_calendar.first.events.map do |v|
      name = v.categories
              .first
                .split(',')
                  .first
                  .downcase
                  .sub(/episodes$/, '')
                  .strip
                  .gsub('ū', 'u')
                  .gsub('ō', 'o')
                  .gsub('×', 'x')
                  .gsub('é', 'e')

      id = Fixes.include?(name) ? Fixes[name] : nil

      {
        start_at: v.dtstart - 4.hours,
        episode: v.uid.split('_').last.to_i,
        anime_name: name,
        anime_id: id
      }
    end
    return if calendar.empty?
    AnimeCalendar.delete_all

    calendar_names = calendar.map {|v| v[:anime_name] }.uniq
    fixed_calendar_names = calendar_names.map {|v| self.hashname(v) }.uniq

    replaced = "replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(%s, '♪', ''), '☆', ''), 'The ', ''), 'the ', ''), '''', ''), '?', ''), '!', ''), ':', ''), '-', ''), ' ', ''), '.', ''), ',', '')"
    query = "#{replaced % 'name'} in ('#{fixed_calendar_names.join("','")}')"
    fixed_calendar_names.each do |v|
      query += " or #{replaced % 'name'} like '%#{v}%'"
      query += " or #{replaced % 'english'} like '%#{v}%'"
      query += " or #{replaced % 'synonyms'} like '%#{v}%'"
      query += " or #{replaced % 'japanese'} like '%#{v}%'"
    end

    query += " or id in (#{calendar.map {|v| v[:anime_id] }.compact.join(',')})"

    #animes = Anime.where(:id => 10464).where(query).inject({}) do |data,anime|
    animes = (Anime.latest + Anime.ongoing.where(query).all + Anime.anons.where(query).all).select {|v| v.kind == 'TV' || v.kind == 'ONA' || v.id == 15133 }.inject({}) do |data,anime|
      data[self.hashname(anime.name)] = anime
      data[anime.id] = anime
      anime.synonyms.each {|v| data[self.hashname(v)] = anime } if anime.synonyms
      anime.japanese.each {|v| data[self.hashname(v)] = anime } if anime.japanese
      anime.english.each {|v| data[self.hashname(v)] = anime } if anime.english
      data
    end

    cache = {}
    imported = Set.new

    batch = []

    calendar.each do |v|
      key = self.hashname(v[:anime_name])
      entry = animes[key] || animes[v[:anime_id]]

      next unless entry
      next if cache.include?(entry.id) && cache[entry.id].include?(v[:episode])
      v[:episode] -= EpisodesDiff[v[:anime_name]] if EpisodesDiff[v[:anime_name]]

      batch << AnimeCalendar.new({
          episode: v[:episode],
          start_at: v[:start_at],
          anime_id: entry.id
        })
      imported << v[:anime_name]
    end
    AnimeCalendar.import batch

    Rails.cache.write 'calendar_unrecognized', (calendar_names - imported.to_a)

    {
      :imported => imported,
      :unrecognized => calendar_names - imported.to_a
    }
  end

  # получение календаря аниме с animecalendar.net
  def self.load_calendar
    content = Proxy.get('http://animecalendar.net/user/ical/8831/e599e8323643658c14eef67e85bdb534', timeout: 30, required_text: 'Calendar for TV from AnimeCalendar', no_proxy: true)
    Icalendar.parse(content)
  end

  def self.hashname(name)
    name.downcase.gsub(/the /, '').gsub(/[ :,.!?'☆♪-]+/, '')
  end
end
