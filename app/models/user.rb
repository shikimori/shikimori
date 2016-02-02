# TODO: refactor UserNotifications module inclusion
class User < ActiveRecord::Base
  include PermissionsPolicy
  include UserNotifications
  include Commentable
  include User::Roles
  include User::TokenAuthenticatable

  MAX_NICKNAME_LENGTH = 20
  LAST_ONLINE_CACHE_INTERVAL = 5.minutes
  MINIMUM_LIFE_INTERVAL = 1.day

  CENCORED_AVATAR_IDS = Set.new [4357, 24433, 48544]

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :async

  has_one :preferences, dependent: :destroy, class_name: UserPreferences.name
  accepts_nested_attributes_for :preferences

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

  #has_many :topic_views
  has_many :history, class_name: UserHistory.name, dependent: :destroy

  has_many :friend_links, foreign_key: :src_id, dependent: :destroy
  has_many :friends, through: :friend_links, source: :dst, dependent: :destroy

  has_many :favourites, dependent: :destroy
  has_many :favourite_seyu, -> { where kind: Favourite::Seyu }, class_name: Favourite.name, dependent: :destroy
  has_many :favourite_producers, -> { where kind: Favourite::Producer }, class_name: Favourite.name, dependent: :destroy
  has_many :favourite_mangakas, -> { where kind: Favourite::Mangaka }, class_name: Favourite.name, dependent: :destroy
  has_many :favourite_persons, -> { where kind: Favourite::Person }, class_name: Favourite.name, dependent: :destroy

  has_many :fav_animes, through: :favourites, source: :linked, source_type: Anime.name
  has_many :fav_mangas, through: :favourites, source: :linked, source_type: Manga.name
  has_many :fav_characters, through: :favourites, source: :linked, source_type: Character.name
  has_many :fav_persons, through: :favourite_persons, source: :linked, source_type: Person.name
  has_many :fav_people, through: :favourites, source: :linked, source_type: Person.name
  has_many :fav_seyu, through: :favourite_seyu, source: :linked, source_type: Person.name
  has_many :fav_producers, through: :favourite_producers, source: :linked, source_type: Person.name
  has_many :fav_mangakas, through: :favourite_mangakas, source: :linked, source_type: Person.name

  has_many :messages, foreign_key: :to_id, dependent: :destroy

  has_many :reviews, dependent: :destroy
  has_many :votes, dependent: :destroy

  has_many :ignores, dependent: :destroy
  has_many :ignored_users, through: :ignores, source: :target

  has_many :club_roles, dependent: :destroy
  has_many :clubs, through: :club_roles

  has_many :versions, dependent: :destroy

  has_many :contest_user_votes, dependent: :destroy
  has_many :topics, class_name: Entry.name
  has_many :topic_ignores, dependent: :destroy

  has_many :comment_views, dependent: :destroy
  has_many :entry_views, dependent: :destroy

  has_many :nickname_changes, class_name: UserNicknameChange.name, dependent: :destroy
  has_many :recommendation_ignores, dependent: :destroy

  has_many :bans, dependent: :destroy
  has_many :club_bans, dependent: :destroy

  has_many :devices, dependent: :destroy

  has_many :user_tokens
  has_many :user_images

  has_many :anime_video_reports

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
    url: '/images/user/:style/:id.:extension',
    path: ':rails_root/public/images/user/:style/:id.:extension',
    default_url: '/assets/globals/missing_avatar/:style.png'

  validates :nickname, presence: true
  validates :nickname, name: true, length: { maximum: MAX_NICKNAME_LENGTH }, if: -> { new_record? || changes['nickname'] }
  validates :email, presence: true, if: -> { persisted? && changes['email'] }
  validates :avatar, attachment_content_type: { content_type: /\Aimage/ }

  before_update :log_nickname_change, if: -> { changes['nickname'] }

  # из этого хука падают спеки user_history_rate. хз почему. надо копаться.
  after_create :create_history_entry unless Rails.env.test?
  after_create :create_preferences!, unless: :preferences
  after_create :check_ban
  # personal message from me
  after_create :send_wellcome_message unless Rails.env.test?
  after_create :grab_avatar unless Rails.env.test?

  scope :suspicious, -> {
    where('sign_in_count < 7')
      .where('users.id not in (select distinct(user_id) from comments)')
      .where('users.id not in (select distinct(user_id) from user_rates)')
  }

  enumerize :language,
    in: [:russian, :english],
    default: :russian,
    predicates: true

  accepts_nested_attributes_for :preferences

  # allows for account creation from twitter & fb
  # allows saves w/o password
  def password_required?
    (!persisted? && user_tokens.empty?) || password.present? || password_confirmation.present?
  end

  # зачистка никнейма от запрещённых символов
  def nickname= value
    fixed_nickname = value
      .gsub(/[%&#\/\\?+><\]\[:,@]+/, '')
      .gsub(/[[:space:]]+/, ' ')
      .strip
      .gsub(/^\.$/, 'точка')

    super Banhammer.instance.censor(fixed_nickname)
  end

  # allows for account creation from twitter
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

  def self.find_by_nickname nick
    method_missing(:find_by_nickname, nick.gsub('+', ' '))
  end

  # мужчина ли это
  def male?
    self.sex && self.sex == 'male' ? true : false
  end

  # женщина ли это
  def female?
    self.sex && self.sex == 'female' ? true : false
  end

  # бот ли пользователь
  def bot?
    BotsService.posters.include?(id) || id == COSPLAYER_ID
  end

  def censored?
    CENCORED_AVATAR_IDS.include?(id)
  end

  # last online time from memcached/or from database
  def last_online_at
    cached = Rails.cache.read(self.last_online_cache_key)
    cached = Time.zone.parse(cached) if cached
    [cached, self[:last_online_at], current_sign_in_at, created_at].compact.max
  end

  # updates user's last online date
  def update_last_online
    now = Time.zone.now
    if self[:last_online_at].nil? || now - User::LAST_ONLINE_CACHE_INTERVAL > self[:last_online_at]
      update_column :last_online_at, now
    else
      Rails.cache.write last_online_cache_key, now.to_s # wtf? Rails is crushed when it loads Time.zone type from memcached
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
    return if self.messages.where(kind: MessageType::ProfileCommented).
                            where(read: false).
                            count > 0
    return if comment.user_id == comment.commentable_id &&
              comment.commentable_type == User.name
    Message.create(
      to_id: id,
      from_id: comment.user_id,
      kind: MessageType::ProfileCommented
    )
  end

  def ignores? user
    cached_ignores.any? { |v| v.target_id == user.id }
  end

  def friended? user
    friend_links.any? {|v| v.dst_id == user.id }
  end

  # ключ для кеша по дате изменения пользователя
  def cache_key
    "#{self.id}_#{self.updated_at.to_i}"
  end

  def banned?
    !!(read_only_at && read_only_at > Time.zone.now)
  end

  def remember_me
    true
  end

  def avatar_url size
    if censored?
      "http://www.gravatar.com/avatar/%s?s=%i&d=identicon" %
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
    created_at + MINIMUM_LIFE_INTERVAL <= Time.zone.now
  end

private

  # создание первой записи в историю - о регистрации на сайте
  def create_history_entry
    history.create! action: UserHistoryAction::Registration
  end

  # запоминаем предыдущие никнеймы пользователя
  def log_nickname_change
    UserNicknameChange.create user: self, value: changes['nickname'][0]
  end

  # создание послерегистрационного приветственного сообщения пользователю
  def send_wellcome_message
    NotificationsService.new(self).user_registered
  end

  def grab_avatar
    return if avatar.exists?
    gravatar_url = "http://www.gravatar.com/avatar/%s?s=%i&d=identicon" %
      [Digest::MD5.hexdigest(email.downcase), 160]

    update avatar: open(gravatar_url)
  end

  def cached_ignores
    @ignores ||= ignores
  end

  def self.find_by_nickname nickname
    where(nickname: nickname)
      .find {|v| v.nickname == nickname }
  end

  def check_ban
    ProlongateBan.perform_in 10.seconds, id
  end
end
