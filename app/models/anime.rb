# TODO: extract torrents to value object
# TODO: move check_status, update_news to service object
# TODO: refactor serialized fields to postgres arrays
class Anime < DbEntry
  include AniManga

  DESYNCABLE = %w(
    name kind episodes rating aired_on released_on status genres
    description_en image
  )
  EXCLUDED_ONGOINGS = %w(966 1199 1960 2406 4459 6149 7511 7643 8189 8336 8631
    8687 9943 9947 10506 10797 10995 12393 13165 13433 13457 13463 15111 15749
    16908 18227 18845 18941 19157 19445 19825 20261 21447 21523 24403 24969
    24417 24835 25503 27687 26453 26163 27519 30131 29361 27785 29099 28247
    28887 30144 29865 29722 29846 30342 30411 30470 30417 30232 30892 30989
    31071 30777 31078 966 31539 30649 31555 30651 31746 31410 31562 32274
    31753
  )

  ADULT_RATING = 'rx'
  SUB_ADULT_RATING = 'r_plus'

  # TODO: refactor to postgres array
  serialize :english
  serialize :japanese
  serialize :synonyms
  # TODO: remove this fields
  serialize :world_art_synonyms
  serialize :mal_scores
  serialize :ani_db_scores
  serialize :world_art_scores

  has_and_belongs_to_many :genres
  has_and_belongs_to_many :studios

  has_many :person_roles, dependent: :destroy
  has_many :characters, through: :person_roles
  has_many :people, through: :person_roles

  has_many :rates,
    -> { where target_type: Anime.name },
   class_name: UserRate.name,
   foreign_key: :target_id,
   dependent: :destroy

  has_many :topics,
    -> { order updated_at: :desc },
    class_name: Entry.name,
    as: :linked,
    dependent: :destroy

  has_many :news,
    -> { order created_at: :desc },
    class_name: Topics::NewsTopic.name,
    as: :linked

  has_many :episodes_news,
    -> { where(action: AnimeHistoryAction::Episode).order(created_at: :desc) },
    class_name: Topics::NewsTopic.name,
    as: :linked

  has_many :related,
    class_name: RelatedAnime.name,
    foreign_key: :source_id,
    dependent: :destroy
  has_many :related_animes,
    -> { where.not related_animes: { anime_id: nil } },
    through: :related,
    source: :anime
  has_many :related_mangas,
    -> { where.not related_animes: { manga_id: nil } },
    through: :related,
    source: :manga

  has_many :similar,
    -> { order id: :desc },
    class_name: SimilarAnime.name,
    foreign_key: :src_id,
    dependent: :destroy
  has_many :links, class_name: AnimeLink.name, dependent: :destroy

  has_many :user_histories,
    -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy
  has_many :cosplay_galleries,
    -> { where deleted: false, confirmed: true },
    through: :cosplay_gallery_links

  has_many :reviews,
    -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :screenshots, -> { where(status: nil).order(:position, :id) }, inverse_of: :anime
  has_many :all_screenshots, class_name: Screenshot.name, dependent: :destroy

  has_many :videos, -> { where(state: 'confirmed').order(:id) }
  has_many :all_videos, class_name: Video.name, dependent: :destroy

  has_many :recommendation_ignores, -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :anime_calendars, dependent: :destroy

  has_many :anime_videos, -> { order :episode }, dependent: :destroy
  has_many :episode_notifications, dependent: :destroy

  has_many :name_matches,
    -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_attached_file :image,
    styles: {
      original: ['225x350>', :jpg],
      preview: ['160x240>', :jpg],
      x96: ['96x150#', :jpg],
      x48: ['48x75#', :jpg]
    },
    #convert_options: {
      #original: " -gravity center -crop '225x310+0+0'",
      #preview: " -gravity center -crop '160x220+0+0'"
    #},
    url: '/system/animes/:style/:id.:extension',
    path: ':rails_root/public/system/animes/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style.jpg'

  enumerize :kind,
    in: [:tv, :movie, :ova, :ona, :special, :music],
    predicates: { prefix: true }
  enumerize :origin,
    in: [:original, :manga, :visual_novel, :game, :unknown, :picture_book]
  enumerize :status, in: [:anons, :ongoing, :released], predicates: true
  enumerize :rating,
    in: [:none, :g, :pg, :pg_13, :r, :r_plus, :rx],
    predicates: { prefix: true }

  validates :name, presence: true
  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  before_save :check_status
  after_save :update_news
  after_create :generate_name_matches

  def episodes= value
    value.blank? ? super(0) : super(value)
  end

  def latest?
    ongoing? || anons? || (aired_on && aired_on > 1.year.ago)
  end

  def adult?
    censored || ADULT_RATING == rating || (
      SUB_ADULT_RATING == rating &&
      ((kind_ova? && episodes <= AnimeVideo::R_OVA_EPISODES) || kind_special?)
    )
  end

  def name
    self[:name].gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip if self[:name].present?
  end

  # название на торрентах. фикс на случай пустой строки
  def torrents_name
    self[:torrents_name].present? ? self[:torrents_name] : nil
  end

  # Subtitles
  def subtitles
    BlobData.get("anime_%d_subtitles" % id) || {}
  end

  # перед сохранением посмотрим, какой стоит статус, и не надо ли его откатить
  def check_status
    return unless changes['status']

    # anons => ongoing
    if changes['status'][0] == 'anons' && changes['status'][1] == 'ongoing'
      # у которого дата старта больше текущей более, чем на 1 день, не делаем онгоинггом
      if aired_on && aired_on > Time.zone.now + 1.day
        self.status = :anons
      end

    # ongoings => released
    elsif changes['status'][0] == 'ongoing' && changes['status'][1] == 'released'
      if released_on
        # one episode left
        if episodes_aired + 1 == episodes && released_on > Time.zone.today - 1.day
          self.status = :ongoing
        end

        # released_on in the future
        if released_on > Time.zone.today
          self.status = :ongoing
        end
      end
    end
  end

  # при сохранении аниме проверка того, что изменилось и создание записей в историю при необходимости
  def update_news
    return unless changed?

    resave = false
    no_news = false

    # анонс, у которого появились вышедшие эпизоды, делаем онгоигом
    if anons? && changes['episodes_aired'] && episodes_aired > 0
      self.status = :ongoing
      resave = true
    end
    # онгоинг, у которого вышел последний эпизод, делаем релизом
    if ongoing? && changes['episodes_aired'] && episodes_aired == episodes && episodes != 0
      self.status = :released
      resave = true
    end

    # при сбросе числа вышедщих эпизодов удаляем новости эпизодов
    if changes['episodes_aired'] && episodes_aired == 0 && changes['episodes_aired'][0] != nil
      Topics::NewsTopic
        .where(linked: self)
        .where(action: AnimeHistoryAction::Episode)
        .destroy_all
      no_news = true
    end

    if changes['status'] && changes['status'][0] != status && !no_news
      if released? && changes['id'].nil? &&
          changes['status'].any? && (released_on || aired_on) &&
          ((!released_on && aired_on > Time.zone.now - 15.month) ||
          (released_on && released_on > Time.zone.now - 1.month))
        entry = GenerateNews::EntryRelease.call self
        # TODO: remove commented code
        # if resave
          self.released_on = entry.created_at
        # else
          # update_column :released_on, entry.created_at
        # end
      end
      GenerateNews::EntryAnons.call self if anons? && changes['status'][0] != 'ongoing'
      GenerateNews::EntryOngoing.call self if ongoing? && changes['status'][0] != 'released'
    end

    self.save if resave
  end

  # torrents
  # TODO: extract this shit to another class
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
end
