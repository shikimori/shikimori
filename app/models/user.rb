# TODO: refactor UserNotifications module inclusion
class User < ApplicationRecord
  include PermissionsPolicy
  include Commentable
  include User::Notifications
  include User::TokenAuthenticatable
  include StylesConcern
  include ElasticsearchConcern

  MAX_NICKNAME_LENGTH = 20
  LAST_ONLINE_CACHE_INTERVAL = 5.minutes
  DAY_LIFE_INTERVAL = 1.day
  WEEK_LIFE_INTERVAL = 1.week

  ACTIVE_SITE_USER_INTERVAL = 1.month

  MORR_ID = 1
  GUEST_ID = 5
  BANHAMMER_ID = 6_942
  COSPLAYER_ID = 1_680

  devise(*%i[
    database_authenticatable
    registerable
    recoverable
    trackable
    validatable
    omniauthable
  ])

  acts_as_voter

  has_one :preferences, dependent: :destroy, class_name: UserPreferences.name
  accepts_nested_attributes_for :preferences

  has_many :achievements, dependent: :destroy
  has_many :comments_all, class_name: Comment.name, dependent: :destroy
  has_many :abuse_requests, dependent: :destroy

  has_many :anime_rates, -> { where target_type: Anime.name },
    class_name: UserRate.name,
    source: :target_id,
    dependent: :destroy

  has_many :manga_rates, -> { where target_type: Manga.name },
    class_name: UserRate.name,
    source: :target_id,
    dependent: :destroy

  has_many :topic_viewings, dependent: :delete_all
  has_many :comment_viewings, dependent: :delete_all

  has_many :history, class_name: UserHistory.name, dependent: :destroy

  has_many :friend_links, foreign_key: :src_id, dependent: :destroy
  has_many :friends, through: :friend_links, source: :dst

  has_many :favourites, dependent: :destroy
  has_many :favourite_seyu, -> { where kind: Favourite::Seyu },
    class_name: Favourite.name
  has_many :favourite_producers, -> { where kind: Favourite::Producer },
    class_name: Favourite.name
  has_many :favourite_mangakas, -> { where kind: Favourite::Mangaka },
    class_name: Favourite.name
  has_many :favourite_persons, -> { where kind: Favourite::Person },
    class_name: Favourite.name

  has_many :fav_animes, through: :favourites, source: :linked, source_type: Anime.name
  has_many :fav_mangas, through: :favourites, source: :linked, source_type: Manga.name
  has_many :fav_ranobe, through: :favourites, source: :linked, source_type: Ranobe.name
  has_many :fav_characters, through: :favourites, source: :linked, source_type: Character.name
  has_many :fav_persons, through: :favourite_persons, source: :linked, source_type: Person.name
  has_many :fav_people, through: :favourites, source: :linked, source_type: Person.name
  has_many :fav_seyu, through: :favourite_seyu, source: :linked, source_type: Person.name
  has_many :fav_producers, through: :favourite_producers, source: :linked, source_type: Person.name
  has_many :fav_mangakas, through: :favourite_mangakas, source: :linked, source_type: Person.name

  has_many :messages, foreign_key: :to_id, dependent: :destroy

  has_many :reviews, dependent: :destroy

  has_many :ignores, dependent: :destroy
  has_many :ignored_users, through: :ignores, source: :target

  has_many :club_roles, dependent: :destroy
  has_many :club_admin_roles, -> { where role: :admin },
    class_name: ClubRole.name
  has_many :clubs, through: :club_roles

  has_many :collections, dependent: :destroy

  has_many :versions, dependent: :destroy

  has_many :topics, class_name: Topic.name
  has_many :topic_ignores, dependent: :destroy
  has_many :ignored_topics, through: :topic_ignores, source: :topic

  has_many :nickname_changes,
    class_name: UserNicknameChange.name,
    dependent: :destroy
  has_many :recommendation_ignores, dependent: :destroy

  has_many :bans, dependent: :destroy
  has_many :club_bans, dependent: :destroy

  has_many :devices, dependent: :destroy

  has_many :user_tokens, dependent: :destroy
  has_many :user_images, dependent: :destroy

  has_many :anime_video_reports
  has_many :list_imports, -> { order id: :desc },
    dependent: :destroy
  has_many :polls, -> { order id: :desc },
    dependent: :destroy

  enumerize :roles,
    in: Types::User::Roles.values,
    predicates: true,
    multiple: true

  has_attached_file :avatar,
    styles: {
      #original: ['300x300>', :png],
      x160: ['160x160#', :png],
      x148: ['148x148#', :png],
      x80: ['80x80#', :png],
      x73: ['73x73#', :png],
      x64: ['64x64#', :png],
      x48: ['48x48#', :png],
      x32: ['32x32#', :png],
      x20: ['20x20#', :png],
      x16: ['16x16#', :png]
    },
    url: '/system/users/:style/:id.:extension',
    path: ':rails_root/public/system/users/:style/:id.:extension',
    default_url: '/assets/globals/missing_avatar/:style.png'

  validates :nickname, presence: true
  validates :nickname,
    name: true,
    length: { maximum: MAX_NICKNAME_LENGTH },
    if: -> { new_record? || will_save_change_to_nickname? }
  validates :email,
    presence: true,
    if: -> { persisted? && will_save_change_to_email? }
  validates :avatar, attachment_content_type: { content_type: /\Aimage/ }

  after_update :log_nickname_change, if: -> { saved_change_to_nickname? }

  # из этого хука падают спеки user_history_rate. хз почему. надо копаться.
  after_create :create_history_entry
  after_create :create_preferences!, unless: :preferences
  # after_create :check_ban
  after_create :send_welcome_message
  after_create :grab_avatar

  SUSPISIOUS_USER_IDS = %w[
    138042 178102 102017 147424 52404 39861 38300 48671
    99709 102017 178102 147424 159414 138042 166784 226642
  ].map(&:to_i)
  SUSPISIOUS_USERS_SQL = <<~SQL.squish
    (
      sign_in_count < 7 and
        users.id not in (select distinct(user_id) from comments) and
        users.id not in (select distinct(user_id) from user_rates)
    ) or users.id in (#{SUSPISIOUS_USER_IDS.join ','})
  SQL
  scope :suspicious, -> { where SUSPISIOUS_USERS_SQL }

  enumerize :locale,
    in: Types::Locale.values,
    default: Types::Locale[:ru]
  enumerize :locale_from_host,
    in: Types::Locale.values,
    default: Types::Locale[:ru]

  accepts_nested_attributes_for :preferences

  # allows for account creation from twitter & fb
  # allows saves w/o password
  def password_required?
    (!persisted? && user_tokens.empty?) ||
      password.present? ||
      password_confirmation.present?
  end

  def nickname= value
    super FixName.call(value, true)
  end

  # allow account creation from twitter
  def email_required?
    user_tokens.empty?
  end

  #TODO: remove
  def all_history
    @all_history ||= history
      .includes(:anime, :manga)
      .order(updated_at: :desc, id: :desc)
  end

  #TODO: remove
  def anime_history
    @anime_history ||= history
      .where(target_type: [Anime.name, Manga.name])
      .includes(:anime, :manga)
  end

  #TODO: remove
  def anime_uniq_history
    @anime_uniq_history ||= anime_history
      .group(:target_id)
      .order('max(updated_at) desc')
      .select('*, max(updated_at) as updated_at')
  end

  def to_param
    nickname.gsub(/ /, '+')
  end

  def self.param_to text
    text.gsub(/\+/, ' ')
  end

  # мужчина ли это
  def male?
    self.sex && self.sex == 'male' ? true : false
  end

  # женщина ли это
  def female?
    self.sex && self.sex == 'female' ? true : false
  end

  # last online time from memcached/or from database
  def last_online_at
    return Time.zone.now if new_record?

    cached = Rails.cache.read(last_online_cache_key)
    cached = Time.zone.parse(cached) if cached
    [cached, self[:last_online_at], current_sign_in_at, created_at].compact.max
  end

  # updates user's last online date
  def update_last_online
    now = Time.zone.now
    if self[:last_online_at].nil? || now - User::LAST_ONLINE_CACHE_INTERVAL > self[:last_online_at]
      update_column :last_online_at, now
    else
      # wtf? Rails is crushed when it loads Time.zone type from memcached
      Rails.cache.write last_online_cache_key, now.to_s
    end
  end

  def last_online_cache_key
    'user_%d_last_online' % self.id
  end

  def can_post?
    !read_only_at || !banned?
  end

  # может ли пользователь сейчас голосовать за указанный контест?
  def can_vote? contest
    contest.started? && self[contest.user_vote_key]
  end
  # может ли пользователь сейчас голосовать за первый турнир?
  def can_vote_1?
    can_vote_1
  end
  # может ли пользователь сейчас голосовать за второй турнир?
  def can_vote_2?
    can_vote_2
  end
  # может ли пользователь сейчас голосовать за третий турнир?
  def can_vote_3?
    can_vote_3
  end

  def favoured? entry, kind=nil
    @favs ||= favourites.to_a
    @favs.any? { |v| v.linked_id == entry.id && v.linked_type == entry.class.name && (kind.nil? || v.kind == kind) }
  end

  # колбек, который вызовет comments_controller при добавлении комментария в профиле пользователя
  def comment_added comment
    return if self.messages.where(kind: MessageType::ProfileCommented).where(read: false).any?
    return if comment.user_id == comment.commentable_id && comment.commentable_type == User.name

    Message.create(
      to_id: id,
      from_id: comment.user_id,
      kind: MessageType::ProfileCommented
    )
  end

  def ignores? user
    ignores.any? { |v| v.target_id == user.id }
  end

  def friended? user
    friend_links.any? { |v| v.dst_id == user.id }
  end

  # ключ для кеша по дате изменения пользователя
  def cache_key
    "#{id}_#{updated_at.to_i}"
  end

  def banned?
    !!(read_only_at && read_only_at > Time.zone.now)
  end

  def active?
    (last_sign_in_at && last_sign_in_at > ACTIVE_SITE_USER_INTERVAL.ago) ||
      (
        self[:last_online_at] &&
        self[:last_online_at] > ACTIVE_SITE_USER_INTERVAL.ago
      )
  end

  def avatar_url size
    if censored_avatar?
      "//www.gravatar.com/avatar/%s?s=%i&d=identicon" %
        [Digest::MD5.hexdigest('takandar+censored@gmail.com'), size]
    else
      ImageUrlGenerator.instance.url self, "x#{size}".to_sym
    end
  end

  def forever_banned?
    (read_only_at || Time.zone.now) - 1.year > Time.zone.now
  end

  # регистрация более суток тому назад
  def day_registered?
    created_at + DAY_LIFE_INTERVAL <= Time.zone.now
  end

  # регистрация более суток тому назад
  def week_registered?
    created_at + WEEK_LIFE_INTERVAL <= Time.zone.now
  end

  # for async mails for Devise 4
  def send_devise_notification notification, *args
    ShikiMailer.delay_for(0.seconds).send(notification, self, *args)
  end

private

  # создание первой записи в историю - о регистрации на сайте
  def create_history_entry
    history.create! action: UserHistoryAction::Registration
  end

  # запоминаем предыдущие никнеймы пользователя
  def log_nickname_change
    Users::LogNicknameChange.call self, saved_changes[:nickname].first
  end

  # создание послерегистрационного приветственного сообщения пользователю
  def send_welcome_message
    Messages::CreateNotification.new(self).user_registered
  end

  def grab_avatar
    return if avatar.exists?
    gravatar_url = 'http://www.gravatar.com/avatar/%s?s=%i&d=identicon' %
      [Digest::MD5.hexdigest(email.downcase), 160]

    update avatar: open(gravatar_url)

  rescue *Network::FaradayGet::NET_ERRORS
    update avatar: open('app/assets/images/globals/missing_avatar/x160.png')
  end

  # def check_ban
    # ProlongateBan.perform_in 10.seconds, id
  # end
end
