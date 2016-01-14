# TODO: удалить поле permalinked
class Club < ActiveRecord::Base
  has_many :member_roles, class_name: ClubRole.name, dependent: :destroy
  has_many :members, through: :member_roles, source: :user

  #has_many :moderator_roles, -> { where role: ClubRole::Moderator }, class_name: ClubRole.name
  #has_many :moderators, through: :moderator_roles, source: :user

  has_many :admin_roles, -> { where role: :admin }, class_name: ClubRole.name
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
  has_many :bans, dependent: :destroy, class_name: ClubBan.name
  has_many :banned_users, through: :bans, source: :user

  has_many :topics, -> { order updated_at: :desc },
    class_name: Entry.name,
    as: :linked,
    dependent: :destroy

  has_one :thread, -> { where linked_type: Club.name },
    class_name: Topics::EntryTopics::ClubTopic.name,
    foreign_key: :linked_id,
    dependent: :destroy

  enum join_policy: { free_join: 1, admin_invite_join: 50, owner_invite_join: 100 }
  enum comment_policy: { free_comment: 1, members_comment: 100 }

  boolean_attribute :censored

  before_save :update_permalink
  after_create :join_owner
  after_create :generate_thread

  has_attached_file :logo,
    styles: {
      main: '215x215>',
      x96: '96x96#',
      x73: '73x73#',
      x48: '48x48#'
    },
    url: '/images/group/:style/:id.:extension',
    path: ':rails_root/public/images/group/:style/:id.:extension',
    default_url: '/images/static/missing_logo_x215.png'

  validates :name, presence: true, name: true
  validates :owner, presence: true
  validates :logo, attachment_content_type: { content_type: /\Aimage/ }

  TRANSLATORSID = 2

  # для урлов
  def to_param
    "#{id}-#{permalink}"
  end

  def joined? user
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

private

  # TODO: remove field permalink
  def update_permalink
    self.permalink = self.name.permalinked if self.changes.include? :name
  end

  def generate_thread
    FayeService
      .new(owner, '')
      .create!(Topics::EntryTopics::ClubTopic.new(
        forum_id: Forum::CLUBS_ID,
        generated: true,
        linked: self,
        user: owner
      ))
  end

  def join_owner
    join owner
  end

  def default_image_url
    "https://github.com/identicons/#{name}.png"
  end
end
