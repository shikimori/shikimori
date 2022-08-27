class Club < ApplicationRecord
  include AntispamConcern
  include TopicsConcern
  include StylesConcern

  antispam(
    per_day: 2,
    user_id_key: :owner_id
  )

  update_index('clubs#club') { self if saved_change_to_name? }
  before_save :check_spam_abuse, if: :will_save_change_to_description?
  after_create :add_to_index # update_index does not wotrk because of second save in StylesConcern

  TRANSLATORS_ID = 2
  SPECIAL_CLUB_IDS = [2046, 202, 72, 2852]

  has_many :member_roles,
    class_name: 'ClubRole',
    dependent: :destroy,
    inverse_of: :club
  has_many :members, through: :member_roles, source: :user

  # has_many :moderator_roles, -> { where role: ClubRole::Moderator },
  #   class_name: ClubRole.name
  # has_many :moderators, through: :moderator_roles, source: :user

  has_many :admin_roles, -> { where role: :admin },
    class_name: 'ClubRole',
    inverse_of: :club
  has_many :admins, through: :admin_roles, source: :user

  has_many :pages, -> { ordered },
    class_name: 'ClubPage',
    dependent: :destroy,
    inverse_of: :club
  has_many :root_pages, -> { where(parent_page_id: nil).ordered },
    class_name: 'ClubPage',
    inverse_of: :club

  has_many :links, class_name: 'ClubLink', dependent: :destroy

  has_many :animes, -> { order :ranked },
    through: :links,
    source: :linked,
    source_type: 'Anime'

  has_many :mangas, -> { order :ranked },
    through: :links,
    source: :linked,
    source_type: 'Manga'

  has_many :ranobe, -> { order :ranked },
    through: :links,
    source: :linked,
    source_type: 'Ranobe'

  has_many :characters, -> { order :name },
    through: :links,
    source: :linked,
    source_type: 'Character'

  has_many :clubs, -> { order :name },
    through: :links,
    source: :linked,
    source_type: 'Club'

  has_many :collections, -> { order :name },
    through: :links,
    source: :linked,
    source_type: 'Collection'

  has_many :images,
    class_name: 'ClubImage',
    dependent: :destroy,
    inverse_of: :club

  belongs_to :owner, class_name: 'User'

  has_many :invites, class_name: 'ClubInvite', dependent: :destroy
  has_many :bans, class_name: 'ClubBan', dependent: :destroy
  has_many :banned_users, through: :bans, source: :user

  enumerize :join_policy,
    in: Types::Club::JoinPolicy.values,
    predicates: { prefix: true },
    default: Types::Club::JoinPolicy[:free]

  enumerize :comment_policy,
    in: Types::Club::CommentPolicy.values,
    predicates: { prefix: true },
    default: Types::Club::CommentPolicy[:free]

  enumerize :topic_policy,
    in: Types::Club::TopicPolicy.values,
    predicates: { prefix: true },
    default: Types::Club::TopicPolicy[:members]

  enumerize :page_policy,
    in: Types::Club::PagePolicy.values,
    predicates: { prefix: true },
    default: Types::Club::TopicPolicy[:admins]

  enumerize :image_upload_policy,
    in: Types::Club::ImageUploadPolicy.values,
    predicates: { prefix: true },
    default: Types::Club::ImageUploadPolicy[:members]

  boolean_attributes :censored, :thematic

  has_attached_file :logo,
    styles: {
      main: '215x215>',
      x96: '96x96#',
      x73: '73x73#',
      x48: '48x48#'
    },
    url: '/system/clubs/:style/:id.:extension',
    path: ':rails_root/public/system/clubs/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style_:style.png'

  validates :name, presence: true, name: true
  validates :logo, attachment_content_type: { content_type: /\Aimage/ }
  validates :locale, presence: true
  validates :description, length: { maximum: 150_000 }, unless: :special_club?
  validates :description, length: { maximum: 300_000 }, if: :special_club?

  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }

  after_create :join_owner
  after_update :sync_topics_is_censored, if: :saved_change_to_is_censored?

  alias topic_user owner

  def to_param
    "#{id}-#{name.permalinked}"
  end

  def name= value
    super FixName.call(value, false)
  end

  def private?
    censored? && !join_policy_free? && !comment_policy_free?
  end

  def member? user
    member_role(user).present?
  end

  def admin? user
    member_role(user).present? && member_role(user).role.admin?
  end

  def owner? user
    owner_id == user.id
  end

  def banned? user
    bans.any? { |v| v.user_id == user.id }
  end

  def invited? user
    invites.any? { |v| v.dst_id == user.id }
  end

  def member_role user
    member_roles.find { |v| v.user_id == user.id }
  end

  # группа ли это переводчиков
  def belongs_to_translators?
    id == TRANSLATORS_ID
  end

  # число участников группы
  def members_count
    club_roles_count
  end

  # отображать ли картинки в группе?
  def display_images?
    display_images
  end

  def ban user
    bans.create! user: user
  end

  def join user
    if owner? user
      admins << user
    else
      members << user
    end
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
  end

  def leave user
    member_roles.where(user: user).destroy_all
  end

private

  def join_owner
    join owner
  end

  def default_image_url
    "https://github.com/identicons/#{name}.png"
  end

  def check_spam_abuse
    throw :abort unless Users::CheckHacked.call(model: self, text: description, user: owner)
  end

  def add_to_index
    ClubsIndex.import self
  rescue StandardError => error
    Bugsnag.notify error if defined? Bugsnag
  end

  def special_club?
    SPECIAL_CLUB_IDS.include? id
  end

  def sync_topics_is_censored
    Clubs::SyncTopicsIsCensored.call self
  end
end
