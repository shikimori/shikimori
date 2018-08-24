# TODO: refactor UserNotifications module inclusion
class User < ApplicationRecord
  include PermissionsPolicy
  include Commentable
  include User::Notifications
  include User::TokenAuthenticatable
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

  has_one :preferences, dependent: :destroy, class_name: UserPreferences.name
  accepts_nested_attributes_for :preferences

  has_many :devices, dependent: :destroy
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

  has_many :fav_animes,
    through: :favourites,
    source: :linked,
    source_type: Anime.name
  has_many :fav_mangas,
    through: :favourites,
    source: :linked,
    source_type: Manga.name
  has_many :fav_ranobe,
    through: :favourites,
    source: :linked,
    source_type: Ranobe.name
  has_many :fav_characters,
    through: :favourites,
    source: :linked,
    source_type: Character.name
  has_many :fav_persons,
    through: :favourite_persons,
    source: :linked,
    source_type: Person.name
  has_many :fav_people,
    through: :favourites,
    source: :linked,
    source_type: Person.name
  has_many :fav_seyu,
    through: :favourite_seyu,
    source: :linked,
    source_type: Person.name
  has_many :fav_producers,
    through: :favourite_producers,
    source: :linked,
    source_type: Person.name
  has_many :fav_mangakas,
    through: :favourite_mangakas,
    source: :linked,
    source_type: Person.name

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
    if: -> { persisted? && will_save_change_to_email? }
  validates :avatar, attachment_content_type: { content_type: /\Aimage/ }

  after_update :log_nickname_change, if: -> { saved_change_to_nickname? }

  # из этого хука падают спеки user_history_rate. хз почему. надо копаться.
  after_create :create_history_entry
  after_create :create_preferences!, unless: :preferences
  # after_create :check_ban
  after_create :send_welcome_message
  before_create :grab_avatar

  SUSPISIOUS_USER_IDS = [
    138042,178102,102017,147424,52404,39861,38300,48671,99709,102017,178102,147424,159414,138042,166784,226642,349048,349049,349050,349051,349053,349057,349059,349063,349064,349065,349066,349067,349068,349069,349070,349071,349072,349073,349074,349075,349076,349077,349078,349079,349081,349083,349084,349085,349086,349087,349088,349089,349090,349091,349092,349094,349096,349098,349100,349101,349102,349103,349104,349105,349107,349108,349109,349111,349112,349114,349115,349210,349212,349213,349215,349216,349217,349219,349220,349221,349223,349224,349225,349226,349227,349228,349230,349231,349232,349233,349234,349235,349236,349238,349239,349240,349241,349242,349243,349244,349247,349248,349249,349250,349251,349252,349254,349256,349258,349259,349260,349261,349262,349263,349264,349265,349267,349268,349269,349270,349272,349292,349294,349303,349304,349305,349306,349307,349308,349309,349310,349314,349410,349411,349412,349413,349414,349415,349417,349418,349419,349420,349421,349422,349423,349424,349425,349426,349427,349428,349429,349430,349431,349432,349433,349434,349435,349436,349437,349438,349439,349440,349441,349442,349443,349444,349445,349446,349447,349448,349449,349450,349451,349452,349453,349454,349455,349456,349457,349459,349460,349461,349479,349480,349481,349482,349483,349484,349485,349486,349487,349488,349489,349491,349492,349493,349494,349495,349496,349497,349498,349499,349500,349501,349502,349503,349504,349505,349506,349507,349508,349509,349511,349512,349513,349515,349516,349517,349518,349519,349520,349521,349522,349523,349524,349525,349526,349527,349528,349529,349530,349531,349532,349534,349535,349536,349537,349538,349539,349540,349541,349542,349543,349544,349545,349548,349549,349550,349551,349552,349553,349554,349555,349556,349557,349558,349559,349560,349561,349562,349563,349564,349565,349566,349567,349568,349569,349570,349571,349572,349573,349574,349575,349576,349577,349578,349579,349580,349581,349582,349583,349584,349585,349586,349587,349588,349589,349590,349591,349592,349593,349595,349596,349597,349598,349599,349600,349601,349602,349603,349604,349605,349606,349607,349608,349609,349610,349611,349612,349613,349614,349631,349632,349634,349636,349637,349638,349639,349640,349641,349642,349643,349644,349645,349646,349647,349648,349649,349650,349651,349652,349653,349654,349655,349656,349657,349658,349659,349660,349661,349662,349663,349664,349665,349666,349667,349668,349669,349670,349671,349672,349673,349674,349676,349677,349678,349679,349680,349681,349682,349683,350243,350244,350245,350251,350252,350253,350254,350257,350258,350259,350260,350261,350264,350265,350266,350267,350269,350270,350271,350272,350273,350274,350275,350276,350277,350278,350279,350281,350282,350283,350285,350286,350287,350288,350289,350290,350291,350292,350293,350294,350296,350297,350298,350336,350337,350338,350339,350340,350342,350345,350346,350347,350348,350349,350350,350351,350353,350355,350356,350357,350358,350359,350361,350363,350365,350366,350367,350368,350369,350371,350372,350373,350374,350375,350376,350377,350378,350380,350382,350383,350384,350385,350386,350387,350388,350389,350390,350391,350392,350393,350394,350395,350396,350398,350399,350400,350401,350402,350403,350404,350405,350407,350408,350409,350410,350411,350412,350413,350414,350415,350417,350804,350805,350806,350807,350808,350809,350810,350811,350812,350813,350817,350821,350822,350823,350824,350825,350826,350827,350828,350829,350833,350834,350835,350836,350837,350838,350839,350840,350841,350842,350843,350844,350845,350846,350847,350848,350849,350850,350851,350852,350853,350854,350855,350856,350857,350858,350859,350860,350861,350862 # rubocop:disable all
  ]
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

  def to_param
    nickname.tr(' ', '+')
  end

  def self.param_to text
    text.tr('+', ' ')
  end

  # мужчина ли это
  def male?
    sex && sex == 'male' ? true : false
  end

  # женщина ли это
  def female?
    sex && sex == 'female' ? true : false
  end

  # last online time from memcached/or from database
  def last_online_at
    return Time.zone.now if new_record?

    cached = ::Rails.cache.read(last_online_cache_key)
    cached = Time.zone.parse(cached) if cached
    [cached, self[:last_online_at], current_sign_in_at, created_at].compact.max
  end

  # updates user's last online date
  def update_last_online
    now = Time.zone.now
    if self[:last_online_at].nil? ||
        now - User::LAST_ONLINE_CACHE_INTERVAL > self[:last_online_at]
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
    return if messages.where(kind: MessageType::ProfileCommented).where(read: false).any?
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

  # for async mails for Devise 4
  def send_devise_notification notification, *args
    ShikiMailer.delay_for(0.seconds).send(notification, self, *args)
  end

  # NOTE: replace id with hashed value of secret token when
  # any private data will be transmitted through the channel
  def faye_channel
    ["user-#{id}"]
  end

private

  def create_history_entry
    history.create! action: UserHistoryAction::Registration
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
      'http://www.gravatar.com/avatar/%<email_hash>s?s=%<size>i&d=identicon',
      email_hash: Digest::MD5.hexdigest(email.downcase),
      size: 160
    )

    self.avatar = OpenURI.open_uri(gravatar_url)
  rescue *Network::FaradayGet::NET_ERRORS
    self.avatar = open('app/assets/images/globals/missing_avatar/x160.png')
  end

  # def check_ban
    # ProlongateBan.perform_in 10.seconds, id
  # end
end
