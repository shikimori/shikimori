class Character < ActiveRecord::Base
  has_many :person_roles, dependent: :destroy
  has_many :animes, -> { order :id }, through: :person_roles
  has_many :mangas, -> { order :id }, through: :person_roles
  has_many :persons, through: :person_roles

  has_many :japanese_roles, -> { where role: 'Japanese' }, class_name: PersonRole.name
  has_many :seyu, through: :japanese_roles, source: :person

  has_many :images, -> { where owner_type: Character.name },
    class_name: AttachedImage.name,
    foreign_key: :owner_id,
    dependent: :destroy

  has_attached_file :image,
    styles: {
      original: ['225x350>', :jpg],
      preview: ['80x120>', :jpg],
      x96: ['64x96#', :jpg],
      x64: ['43x64#', :jpg]
    },
    url: "/images/character/:style/:id.:extension",
    path: ":rails_root/public/images/character/:style/:id.:extension",
    default_url: '/images/missing_:style.jpg'

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  has_one :thread, -> { where linked_type: Character.name },
    class_name: CharacterComment.name,
    foreign_key: :linked_id,
    dependent: :destroy

  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy

  has_many :cosplay_galleries, -> { where deleted: false, confirmed: true },
    through: :cosplay_gallery_links,
    class_name: CosplaySession.name

  after_create :create_thread
  after_save :sync_thread

  before_save -> {
    self.russian = CGI::escapeHTML self.russian || '' if self.changes['russian']
  }

  # Methods
  def to_param
    "%d-%s" % [id, name.gsub(/&#\d{4};/, '-').gsub(/[^A-z0-9]+/, '-').gsub(/^-|-$/, '')]
  end

  # создание CharacterComment для элемента сразу после создания
  def create_thread
    CharacterComment.create! linked: self, generated: true, title: name
  end

  # при сохранении аниме обновление его CommentEntry
  def sync_thread
    if self.changes["name"]
      thread.sync
      thread.save
    end
  end

  # альтернативное имя "в кавычках"
  def altname
    fullname.present? ? fullname.gsub(/^.*?"|".*?$/, '') : nil
  end

  def anime?
    false
  end

  def manga?
    false
  end
end
