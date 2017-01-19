# frozen_string_literal: true

# TODO: удалить поле permalinked
class Club < ActiveRecord::Base
  include TopicsConcern
  include StylesConcern

  has_many :member_roles,
    class_name: ClubRole.name,
    dependent: :destroy,
    inverse_of: :club
  has_many :members, through: :member_roles, source: :user

  #has_many :moderator_roles, -> { where role: ClubRole::Moderator }, class_name: ClubRole.name
  #has_many :moderators, through: :moderator_roles, source: :user

  has_many :admin_roles, -> { where role: :admin },
    class_name: ClubRole.name,
    inverse_of: :club
  has_many :admins, through: :admin_roles, source: :user

  has_many :links, class_name: ClubLink.name, dependent: :destroy

  has_many :animes, -> { order :ranked },
    through: :links,
    source: :linked,
    source_type: Anime.name

  has_many :mangas, -> { order :ranked },
    through: :links,
    source: :linked,
    source_type: Manga.name

  has_many :characters, -> { order :name },
    through: :links,
    source: :linked,
    source_type: Character.name

  has_many :images, as: :owner, dependent: :destroy, inverse_of: :owner

  belongs_to :owner, class_name: User.name, foreign_key: :owner_id

  has_many :invites, class_name: ClubInvite.name, dependent: :destroy
  has_many :bans, class_name: ClubBan.name, dependent: :destroy
  has_many :banned_users, through: :bans, source: :user

  enumerize :join_policy,
    in: Types::Club::JoinPolicy.values,
    predicates: { prefix: true },
    default: Types::Club::JoinPolicy[:free]

  enumerize :comment_policy,
    in: Types::Club::CommentPolicy.values,
    predicates: { prefix: true },
    default: Types::Club::CommentPolicy[:free]

  enumerize :image_upload_policy,
    in: Types::Club::ImageUploadPolicy.values,
    predicates: { prefix: true },
    default: Types::Club::ImageUploadPolicy[:members]

  boolean_attribute :censored

  after_create :join_owner

  has_attached_file :logo,
    styles: {
      main: '215x215>',
      x96: '96x96#',
      x73: '73x73#',
      x48: '48x48#'
    },
    url: '/system/clubs/:style/:id.:extension',
    path: ':rails_root/public/system/clubs/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style_:style.jpg'

  validates :name, presence: true, name: true
  validates :owner, presence: true
  validates :logo, attachment_content_type: { content_type: /\Aimage/ }
  validates :locale, presence: true

  enumerize :locale, in: %i(ru en), predicates: { prefix: true }

  TRANSLATORSID = 2

  # для урлов
  def to_param
    "#{id}-#{name.permalinked}"
  end

  def name= value
    super FixName.call(value, false)
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
    bans.any? {|v| v.user_id == user.id }
  end

  def invited? user
    invites.any? {|v| v.dst_id == user.id }
  end

  def member_role user
    member_roles.find {|v| v.user_id == user.id }
  end

  # группа ли это переводчиков
  def belongs_to_translators?
    id == TRANSLATORSID
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

  # для совместимости с DbEntry
  def description_ru
    description
  end

  # для совместимости с DbEntry
  def description_en
    description
  end

  def topic_user
    owner
  end

private

  def join_owner
    join owner
  end

  def default_image_url
    "https://github.com/identicons/#{name}.png"
  end
end
