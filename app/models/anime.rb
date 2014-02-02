# TODO: переделать kind в enumerize (https://github.com/brainspec/enumerize)
# TODO: extract torrents to value object
# TODO: выпилить matches_for и заменить на использование NameMatcher
class Anime < ActiveRecord::Base
  include AniManga
  EXCLUDED_ONGOINGS = [966, 1199, 1960, 2406, 4459, 6149, 7511, 7643, 8189, 8336, 8687, 9799, 9947, 10506, 10797, 10995, 15749, 7643, 9799, 10856, 13165, 13433, 13463, 13465, 16908, 17733, 18097, 18155, 18191, 19825, 18941, 21447, 19755, 19843, 19157, 20267, 21981, 15389, 12393, 13167, 13457, 15111, 18755, 8631, 18919, 18845, 18365, 18241, 18227, 17697, 17237, 16389, 15865, 9943, 21523, 21433, 19445, 20261]
  ADULT_RATINGS = ['R+ - Mild Nudity', 'Rx - Hentai']

  # Fields
  serialize :english
  serialize :japanese
  serialize :synonyms
  serialize :world_art_synonyms
  serialize :mal_scores
  serialize :ani_db_scores
  serialize :world_art_scores

  # Relations
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :studios

  has_many :person_roles, dependent: :destroy
  has_many :characters, through: :person_roles
  has_many :people, through: :person_roles

  has_many :rates,
   class_name: UserRate.name,
   foreign_key: :target_id,
   conditions: { target_type: self.name },
   dependent: :destroy

  has_many :topics,
    class_name: Entry.name,
    as: :linked,
    order: 'updated_at desc',
    dependent: :destroy

  has_many :news,
    class_name: AnimeNews.name,
    as: :linked,
    order: 'created_at desc'

  has_many :episodes_news,
    class_name: AnimeNews.name,
    as: :linked,
    conditions: { action: AnimeHistoryAction::Episode },
    order: 'created_at desc'

  has_many :related,
    dependent: :destroy,
    foreign_key: :source_id,
    class_name: RelatedAnime.name
  has_many :related_animes,
    through: :related,
    source: :anime,
    conditions: 'anime_id is not null'
  has_many :related_mangas,
    through: :related,
    source: :manga,
    conditions: 'manga_id is not null'

  has_many :similar,
    class_name: SimilarAnime.name,
    foreign_key: :src_id,
    order: 'id desc',
    dependent: :destroy
  has_many :links, class_name: AnimeLink.name, dependent: :destroy

  has_many :user_histories,
    foreign_key: :target_id,
    conditions: { target_type: Anime.name },
    dependent: :destroy

  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy
  has_many :cosplay_galleries,
    through: :cosplay_gallery_links,
    class_name: CosplaySession.name,
    conditions: { deleted: false, confirmed: true }

  has_one :thread,
    class_name: AniMangaComment.name,
    foreign_key: :linked_id,
    conditions: { linked_type: self.name },
    dependent: :destroy

  has_many :reviews,
    foreign_key: :target_id,
    conditions: { target_type: self.name },
    dependent: :destroy

  has_many :images,
    class_name: AttachedImage.name,
    foreign_key: :owner_id,
    conditions: { owner_type: self.name },
    dependent: :destroy

  has_many :screenshots, order: [:position, :id], conditions: { status: nil }
  has_many :all_screenshots, class_name: Screenshot.name, dependent: :destroy

  has_many :videos, order: [:id], conditions: { state: 'confirmed' }
  has_many :all_videos, class_name: Video.name, dependent: :destroy

  has_many :recommendation_ignores,
    conditions: { target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :anime_calendars, dependent: :destroy

  has_many :anime_videos, order: [:episode], dependent: :destroy

  has_attached_file :image,
    styles: {
      original: ['225x350#', :jpg],
      preview: ['160x240>', :jpg],
      x96: ['64x96#', :jpg],
      x64: ['43x64#', :jpg]
    },
    url: "/images/anime/:style/:id.:extension",
    path: ":rails_root/public/images/anime/:style/:id.:extension",
    default_url: '/assets/globals/missing_:style.jpg'

  validates_attachment_content_type :image, content_type: [/^image\/(?:jpeg)$/, nil]

  # Hooks
  after_create :create_thread
  after_save :sync_thread

  before_save :check_status
  after_save :update_news

  # Scopes
  scope :translatable, where {
      kind.eq('TV') | (kind.eq('ONA') & score.gte(7.0)) | (kind.eq('OVA') & score.gte(7.5))
    }.where { id.not_in Anime::EXCLUDED_ONGOINGS }

  # Methods
  def latest?
    self.ongoing? || self.anons? || (self.aired_at && self.aired_at > DateTime.now - 1.year)
  end

  def name
    #self[:name] ? self[:name].gsub(/\(movie\)$/i, '').gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip.html_safe : nil
    if self[:name]
      # временный костыль после миграции на 1.9.3
      (self[:name].encoding.name == 'ASCII-8BIT' ? self[:name].encode('utf-8', undef: :replace, invalid: :replace, replace: '') : self[:name]).
        gsub(/\(movie\)$/i, '').gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip.html_safe
    else
      nil
    end
  end

  def self.latest
    #Anime.where(AniMangaSeason.query_for('latest'))
    Anime.all.select {|v| v.latest? }
  end

  def self.ongoing
    #Anime.order(:id).all.select {|v| v.ongoing? }
    Anime.where(AniMangaStatus.query_for('ongoing'))
  end

  def self.anons
    Anime.where(AniMangaStatus.query_for('planned'))
    #Anime.order(:id).all.select {|v| v.anons? }
  end

  # тип аниме на русском
  def russian_kind
    'Аниме'
  end

  # есть ли файлы у аниме?
  def has_files?
    BlobData.where({key: "anime_%d_torrents" % id} |
                   {key: "anime_%d_torrents_480p" % id} |
                   {key: "anime_%d_torrents_720p" % id} |
                   {key: "anime_%d_torrents_1080p" % id} |
                   {key: "anime_%d_subtitles" % id}).any?
  end

  # Torrents
  def torrents
    @torrents ||= (BlobData.get("anime_%d_torrents" % id) || []).select {|v| v.respond_to?(:[]) }
  end

  def torrents=(data)
    BlobData.set("anime_%d_torrents" % id, data)# unless data.empty?
    @torrents = nil
  end

  def torrents_480p
    @torrents_480p ||= torrents.select {|v| v.kind_of?(Hash) && v[:title] && v[:title].match(/x480|480p/) }.reverse +
      (BlobData.get("anime_%d_torrents_480p" % id) || []).select {|v| v.respond_to?(:[]) }
  end

  def torrents_480p=(data)
    BlobData.set("anime_%d_torrents_480p" % id, data) unless data.empty?
    @torrents_480p = nil
  end

  def torrents_720p
    @torrents_720p = torrents.select {|v| v.kind_of?(Hash) && v[:title] && v[:title].match(/x720|x768|720p/) }.reverse +
      (BlobData.get("anime_%d_torrents_720p" % id) || []).select {|v| v.respond_to?(:[]) }
  end

  def torrents_720p=(data)
    BlobData.set("anime_%d_torrents_720p" % id, data) unless data.empty?
    @torrents_720p = nil
  end

  def torrents_1080p
    @torrents_1080p = torrents.select {|v| v.kind_of?(Hash) && v[:title] && v[:title].match(/x1080|1080p/) }.reverse +
      (BlobData.get("anime_%d_torrents_1080p" % id) || []).select {|v| v.respond_to?(:[]) }
  end

  def torrents_1080p=(data)
    BlobData.set("anime_%d_torrents_1080p" % id, data) unless data.empty?
    @torrents_1080p = nil
  end

  def fill_torrents_cache
    #при поиске эпизода запоминать текущий минимальный, чтобы если торренты в криповм порядке, найти все серии
    #так же вынести торренты 480p на страницу с файлами
    #показывать только если 720p нету
    if latest?
      queries = []
      queries << name
      queries.concat(english) unless english.empty?
      queries.concat(synonyms) unless synonyms.empty?

      check_torrents = Proc.new do |torrents, quality|
        if torrents
          torrents = torrents.select {|v| self.matches_for(v[:title]) }
          #check_aired_episodes(torrents) # не надо этого делать, косяки возникают. тут проверка не такая, как в тошокане
          BlobData.set("anime_%d_torrents_%dp" % [id, quality], torrents) unless torrents.empty?
        end
        torrents && !torrents.empty? ? torrents : nil
      end

      torrents720p = nil
      queries.each do |query|
        torrents720p = BtjunkieParser.nya_rss(query+" 720")
        # дополнительная попытака, если совсем ничего не найдено
        if !torrents720p && query == queries.last
          torrents720p = BtjunkieParser.nya_rss(query+" 720", :nofilter)
        end
        torrents720p = check_torrents.call(torrents720p, 720)

        next unless torrents720p
        torrents1080p = BtjunkieParser.nya_rss(query+" 1080")
        torrents1080p = check_torrents.call(torrents1080p, 1080)

        break if torrents720p
      end

      torrents480p = nil
      queries.each do |query|
        torrents480p = BtjunkieParser.nya_rss(query+" 480")
        # дополнительная попытака, если совсем ничего не найдено
        if !torrents480p && query == queries.last
          torrents480p = BtjunkieParser.nya_rss(query+" 480", :nofilter)
        end
        torrents480p = check_torrents.call(torrents480p, 480)
        break if torrents480p
      end unless torrents720p

      return torrents720p || torrents480p
    end

    queries = []
    unless name.include?(' ')
      queries << "%s %s" % [name, english.first] unless english.empty?
      queries << "%s %s" % [name, synonyms.first] unless synonyms.empty?
      queries.concat(english) unless english.empty?
      queries.concat(synonyms) unless synonyms.empty?
    end
    queries << name
    queries << name.split(':')[0] if name.include?(':')

    check_torrents = Proc.new do |query, torrents|
      data = torrents.sort_by {|v| -1*v[:size] }.
                      select {|v| v[:size] > (episodes > 50 ? episodes/4 : episodes) * 90 }.
                      select {|v| query.gsub(/\W/, ' ').gsub(/ +/, ' ').split(' ').select {|w| w.size > 2 }.any? {|k| v[:title].downcase.include?(k.downcase) } }
      BlobData.set("anime_%d_torrents" % id, data) unless data.empty?
      data
    end

    # find via rss search
    queries.each do |query|
      torrents = BtjunkieParser.rss(query)
      if torrents
        torrents = check_torrents.call(query, torrents)
        return torrents unless torrents.empty?
      end
    end

    # find via web anime search
    torrents = BtjunkieParser.web_anime(name)
    if torrents
      torrents = check_torrents.call(name, torrents)
      return torrents unless torrents.empty?
    end

    # find via web search
    torrents = BtjunkieParser.web(name)
    if torrents
      torrents = check_torrents.call(name, torrents)
      return torrents unless torrents.empty?
    end
    nil
  end

  # название на торрентах. фикс на случай пустой строки
  def torrents_name
    self[:torrents_name].present? ? self[:torrents_name] : nil
  end

  # все вариации названий аниме
  def name_variants(agains='', options={})
    names = [self.torrents_name || self.name]
    unless options[:only_name] || self.torrents_name
      if self.kind != 'Special'
        names.concat(self.english) unless !self.english || self.english.empty?
        names.concat(self.synonyms) unless !self.synonyms || self.synonyms.empty?
      end
      names << self.name.sub(/ (\d)$/, '\1') if self.name =~ / \d$/
      names << self.name.sub(/ (\d)$/, ' S\1') if self.name =~ / \d$/
    end

    names = names.select {|v| v =~ / \(?(?:ova|tv|special|ona)\)?$/i } if names.any? {|v| v =~ / \(?(?:ova|tv|special|ona)\)?$/i }
    names << self.name + ' tv' if self.name.match(':') && self.kind == 'TV' && !self.name.downcase.include?('tv') && agains.downcase.include?('tv')
    # случай, когда название содержит (tv)
    names << self.name.sub(/\(tv\)/i, '').strip if self.name.downcase.include? '(tv)'
    # тире воспринимаем так же, как пробел
    # 2 воспринимаем как II, а II как 2
    names = names.map do |name|
      [name, name.gsub('-', ' ')].map {|v| [v.gsub('2', 'II'), v.gsub('II', '2')] }.flatten
    end

    ['☆', '/', '†', '♪'].each do |symbol|
      if name.include? symbol
        names << name.gsub(symbol, '')
        names << name.gsub(symbol, ' ')
      end
    end
    names.flatten.uniq
  end

  # совпадает ли название аниме со строкой
  # для совпадения должны совпадать как минимум половина ключевых слов(если их меньше трех, то все)
  # и все спец слова
  def matches_for(title, options={only_name: false, exact_name: false})
    title = title.gsub('​', '').gsub('_', ' ')
    if options[:exact_name] || self.torrents_name.present?
      return title.downcase.include?((torrents_name || name).downcase)
    end

    name_variants(title, options).any? do |query|
      query_keywords = query.keywords
      #long_query_keywords = query_keywords.select {|v| v.size > 2 }
      #query_keywords = long_query_keywords if long_query_keywords.size > 2 && long_query_keywords.size >= query_keywords.size/2
      next if query_keywords.empty?
      title_keywords = title.keywords
      query_specials = query.specials
      overlaps = query_keywords & title_keywords
      matched =
        if options[:only_name]
          overlaps.size == query_keywords.size
        else
          ((query_keywords.size <= 3 && overlaps.size == query_keywords.size) ||
            (query_keywords.size > 6 &&
            query_keywords.include?('tv') &&
            title_keywords.include?('tv') &&
            overlaps.size >= (query_keywords.size.to_f/2.5).floor) ||
            (query_keywords.size > 3 && overlaps.size >= (query_keywords.size.to_f/2).ceil)
          ) && (query_specials & title.specials).size == query_specials.size
        end

#ap [query, query_keywords, title_keywords, matched, season_parts(query)]

      if matched
        parts = season_parts(query)
        if parts
          Regexp.new("%s[\\s\\W]%s" % parts).match(title)
        else
          true
        end
      else
        false
      end
    end
  end

  def season_parts(title)
    parts = title.split(' ')
    return nil if parts.size < 2
    season = parts[parts.size - 1]
    keyword = parts[parts.size - 2]
    if season =~ /(\d|I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII|XIII)\b/
      [keyword.gsub(/\W/, ' ').split(' ').last, season]
    else
      nil
    end
  end

  # Subtitles
  def subtitles
    subtitles = BlobData.get("anime_%d_subtitles" % id) || {}
  end

  # добавление новых эпизодов из rss фида
  def check_aired_episodes(feed)
    episode_min = self.changes["episodes_aired"] || self.episodes_aired || 0
    episode_max = self.episodes_aired || 0
    @episodes_found = [] unless @episodes_found

    new_episodes = []
    feed.reverse.each do |v|
      TorrentsParser.extract_episodes_num(v[:title]).each do |episode|
        next if (self.episodes > 0 && episode > self.episodes) || episode_min >= episode || @episodes_found.include?(episode)
        episode_max = episode if episode_max < episode
        self.episodes_aired = episode
        new_episodes << v
        AnimeNews.create_for_new_episode(self, (v[:pubDate] || DateTime.now) + episode.seconds)
      end
    end
    self.episodes_aired = episode_max
    save if changed?
    return new_episodes.uniq
  end

  # перед сохранением посмотрим, какой стоит статус, и не надо ли его поменять
  def check_status
    # анонс, у которого дата старта больше текущей более, чем на 1 день, не делаем онгоинггом
    if self.changes["status"] && self.status == AniMangaStatus::Ongoing && self.changes["status"][0] == AniMangaStatus::Anons &&
         self.aired_at && self.aired_at > DateTime.now + 1.day
      self.status = AniMangaStatus::Anons
    end

    # онгоинг не может стать Released, пока у него released_at больше текущей даты более, чем на 1 день
    if self.changes["status"] && self.status == AniMangaStatus::Released && self.changes["status"][0] == AniMangaStatus::Ongoing &&
         self.released_at && self.released_at > DateTime.now + 1.day
      self.status = AniMangaStatus::Ongoing
    end

    # синхронизация episodes_aired с episodes при переводе в Released
    #if self.changes["status"] && self.status == AniMangaStatus::Released &&
         #self.episodes_aired > 0 && self.episodes > 0 && self.episodes != self.episodes_aired
      #self.episodes_aired = self.episodes
    #end
  end

  # при сохранении аниме проверка того, что изменилось и создание записей в историю при необходимости
  def update_news
    return unless changed?

    resave = false
    no_news = false

    # анонс, у которого появились вышедшие эпизоды, делаем онгоигом
    if self.status == AniMangaStatus::Anons && self.changes["episodes_aired"] && self.episodes_aired > 0
      self.status = AniMangaStatus::Ongoing
      resave = true
    end
    # онгоинг, у которого вышел последний эпизод, делаем релизом
    if self.status == AniMangaStatus::Ongoing && self.changes["episodes_aired"] && self.episodes_aired == self.episodes && self.episodes != 0
      self.status = AniMangaStatus::Released
      resave = true
    end

    # при сбросе числа вышедщих эпизодов удаляем новости эпизодов
    if self.changes["episodes_aired"] && self.episodes_aired == 0 && self.changes["episodes_aired"][0] != nil
      AnimeNews.where(linked_id: id, linked_type: self.class.name)
               .where(action: AnimeHistoryAction::Episode)
               .destroy_all
      no_news = true
    end

    if self.changes["status"] && self.changes["status"][0] != self.status && !no_news
      if self.status == AniMangaStatus::Released &&
          self.changes["id"].nil? &&
          self.changes["status"].any? &&
          (self.released_at || self.aired_at) &&
          ((!self.released_at && self.aired_at > DateTime.now - 15.month) ||
           (self.released_at && self.released_at > DateTime.now - 1.month))
        AnimeNews.create_for_new_release(self)
      end
      AnimeNews.create_for_new_anons(self) if self.status == AniMangaStatus::Anons && self.changes["status"][0] != AniMangaStatus::Ongoing
      AnimeNews.create_for_new_ongoing(self) if self.status == AniMangaStatus::Ongoing && self.changes["status"][0] != AniMangaStatus::Released
    end
    self.save if resave
  end

  def adult?
    censored || ADULT_RATINGS.include?(rating)
  end
end
