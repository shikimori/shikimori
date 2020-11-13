# TODO: refactor UserNotifications module inclusion
class User < ApplicationRecord
  include PermissionsPolicy
  include Commentable
  include User::NotificationsConcern
  include StylesConcern

  MAX_NICKNAME_LENGTH = 20
  LAST_ONLINE_CACHE_INTERVAL = 5.minutes
  DAY_LIFE_INTERVAL = 1.day
  WEEK_LIFE_INTERVAL = 1.week

  ACTIVE_SITE_USER_INTERVAL = 1.month

  MORR_ID = 1
  GUEST_ID = 5
  BANHAMMER_ID = 6_942
  MESSANGER_ID = Rails.env.test? ? MORR_ID : 1_680

  STAFF_ROLES = %w[
    admin
    super_moderator
    forum_moderator
    version_names_moderator
    version_texts_moderator
    version_moderator
    version_fansub_moderator
    trusted_version_changer
    review_moderator
    collection_moderator
    news_moderator
    article_moderator
    cosplay_moderator
    contest_moderator
    statistics_moderator
  ]

  devise(
    :database_authenticatable,
    :registerable,
    :recoverable,
    :trackable,
    :validatable,
    :omniauthable,
    :doorkeeper
  )

  acts_as_voter
  update_index('users#user') { self if saved_change_to_nickname? }
  after_create :add_to_index # update_index does no work because of second save in StylesConcern

  attribute :last_online_at, :datetime, default: -> { Time.zone.now }

  has_one :preferences, dependent: :destroy, class_name: UserPreferences.name
  accepts_nested_attributes_for :preferences

  has_many :oauth_applications,
    -> { order id: :desc },
    as: :owner,
    dependent: :destroy

  has_many :access_grants,
    class_name: 'Doorkeeper::AccessGrant',
    foreign_key: :resource_owner_id,
    dependent: :destroy
  has_many :access_tokens,
    class_name: 'Doorkeeper::AccessToken',
    foreign_key: :resource_owner_id,
    dependent: :destroy

  has_many :user_tokens, dependent: :destroy

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

  has_many :user_rate_logs, dependent: :destroy

  has_many :topic_viewings, dependent: :delete_all
  has_many :comment_viewings, dependent: :delete_all

  has_many :history, class_name: UserHistory.name, dependent: :destroy

  has_many :friend_links, foreign_key: :src_id, dependent: :destroy
  has_many :friends, through: :friend_links, source: :dst

  has_many :favourites, dependent: :destroy
  has_many :favourite_seyu, -> { where kind: Types::Favourite::Kind[:seyu] },
    class_name: Favourite.name
  has_many :favourite_producers, -> { where kind: Types::Favourite::Kind[:producer] },
    class_name: Favourite.name
  has_many :favourite_mangakas, -> { where kind: Types::Favourite::Kind[:mangaka] },
    class_name: Favourite.name
  has_many :favourite_persons, -> { where kind: Types::Favourite::Kind[:person] },
    class_name: Favourite.name

  has_many :messages, foreign_key: :to_id, dependent: :destroy
  has_many :messages_from, foreign_key: :from_id, dependent: :destroy, class_name: Message.name

  has_many :reviews, dependent: :destroy

  has_many :ignores, dependent: :destroy
  has_many :ignored_users, through: :ignores, source: :target

  has_many :club_roles, dependent: :destroy
  has_many :club_admin_roles, -> { where role: :admin },
    class_name: ClubRole.name
  has_many :clubs, through: :club_roles
  has_many :club_images, dependent: :destroy

  has_many :collections, dependent: :destroy
  has_many :articles, dependent: :destroy

  has_many :versions, dependent: :destroy

  has_many :topics, class_name: Topic.name, dependent: :destroy
  has_many :topic_ignores, dependent: :destroy
  has_many :ignored_topics, through: :topic_ignores, source: :topic

  has_many :nickname_changes,
    class_name: UserNicknameChange.name,
    dependent: :destroy
  has_many :recommendation_ignores, dependent: :destroy

  has_many :bans, dependent: :destroy
  has_many :club_bans, dependent: :destroy

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

  enumerize :notification_settings,
    in: Types::User::NotificationSettings.values,
    predicates: { prefix: true },
    multiple: true

  has_attached_file :avatar,
    styles: {
      # original: ['300x300>', :png],
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
    if: -> {
      persisted? && will_save_change_to_email?
    }
  validates :avatar, attachment_content_type: { content_type: /\Aimage/ }

  after_initialize :fill_notification_settings,
    if: -> { new_record? && notification_settings.none? }
  after_update :log_nickname_change, if: -> { saved_change_to_nickname? }

  # из-за этого хука падают спеки user_history_rate. хз почему. надо копаться.
  after_create :create_history_entry
  after_create :create_preferences!, unless: :preferences
  # after_create :check_ban
  after_create :send_welcome_message
  before_create :grab_avatar

  SUSPISIOUS_USERS_SQL = <<~SQL.squish
    (
      sign_in_count < 7 and
        users.id not in (select distinct(user_id) from comments) and
        users.id not in (select distinct(user_id) from user_rates)
    )
  SQL

  scope :suspicious, -> { where(SUSPISIOUS_USERS_SQL).or(cheat_bot) } # very slow
  scope :cheat_bot, -> { where "roles && '{#{Types::User::Roles[:cheat_bot]}}'" }

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
    new_record? && user_tokens.empty?
  end

  # TODO: remove
  def all_history
    @all_history ||= history
      .includes(:anime, :manga)
      .order(updated_at: :desc, id: :desc)
  end

  # TODO: remove
  def anime_history
    @anime_history ||= history
      .where(target_type: [Anime.name, Manga.name])
      .includes(:anime, :manga)
  end

  def to_param nickname = self.nickname
    nickname.tr(' ', '+')
  end

  def self.param_to text
    text.tr('+', ' ')
  end

  def male?
    !female?
  end

  def female?
    sex && sex == 'female' ? true : false
  end

  # updates user's last online date
  def update_last_online
    now = Time.zone.now

    if last_online_at.nil? || now - User::LAST_ONLINE_CACHE_INTERVAL > last_online_at
      update_column :last_online_at, now
    else
      # wtf? Rails is crushed when it loads Time.zone type from memcached
      ::Rails.cache.write last_online_cache_key, now.to_s
    end
  end

  def last_online_cache_key
    "user_#{id}_last_online"
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

  def favoured? entry, kind = nil
    @favs ||= favourites.to_a
    @favs.any? do |v|
      v.linked_id == entry.id && v.linked_type == entry.class.name &&
        (kind.nil? || v.kind == kind)
    end
  end

  # колбек, который вызовет comments_controller при добавлении комментария в профиле пользователя
  def comment_added comment
    return if messages.where(kind: MessageType::PROFILE_COMMENTED).where(read: false).any?
    return if comment.user_id == comment.commentable_id && comment.commentable_type == User.name

    Message.create(
      to_id: id,
      from_id: comment.user_id,
      kind: MessageType::PROFILE_COMMENTED
    )
  end

  def ignores? user
    ignores.any? { |v| v.target_id == user.id }
  end

  def friended? user
    friend_links.any? { |v| v.dst_id == user.id }
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
      format(
        '//www.gravatar.com/avatar/%<email_hash>s?s=%<size>i&d=identicon',
        email_hash: Digest::MD5.hexdigest('takandar+censored@gmail.com'),
        size: size
      )
    else
      ImageUrlGenerator.instance.url self, "x#{size}".to_sym
    end
  end

  def forever_banned?
    (read_only_at || Time.zone.now) > 1.year.from_now
  end

  def day_registered?
    created_at + DAY_LIFE_INTERVAL <= Time.zone.now
  end

  def week_registered?
    created_at + WEEK_LIFE_INTERVAL <= Time.zone.now
  end

  def staff?
    (roles.to_a & STAFF_ROLES).any?
  end

  def generated_email?
    email.match?(/^generated_\w+/)
  end

  # for async mails for Devise 4
  def send_devise_notification notification, *args
    ShikiMailer.delay_for(0.seconds).send(notification, self, *args)
  end

  # NOTE: replace id with hashed value of secret token when
  # any private data will be transmitted through the channel
  def faye_channel
    ["/user-#{id}"]
  end

private

  def fill_notification_settings
    self.notification_settings = Types::User::NotificationSettings.values
  end

  def create_history_entry
    history.create! action: UserHistoryAction::REGISTRATION
  end

  def log_nickname_change
    Users::LogNicknameChange.call self, saved_changes[:nickname].first
  end

  def send_welcome_message
    Messages::CreateNotification.new(self).user_registered
  end

  def grab_avatar
    return if avatar.exists?

    gravatar_url = format(
      'https://www.gravatar.com/avatar/%<email_hash>s?s=%<size>i&d=identicon',
      email_hash: Digest::MD5.hexdigest(email.downcase),
      size: 160
    )

    NamedLogger.download_avatar.info "#{gravatar_url} start"
    self.avatar = OpenURI.open_uri(gravatar_url)
    NamedLogger.download_avatar.info "#{gravatar_url} end"

  rescue *Network::FaradayGet::NET_ERRORS
    self.avatar = open('app/assets/images/globals/missing_avatar/x160.png')
  end

  # def check_ban
    # ProlongateBan.perform_in 10.seconds, id
  # end

  def add_to_index
    UsersIndex.import self
  rescue StandardError => _e
  end
end
