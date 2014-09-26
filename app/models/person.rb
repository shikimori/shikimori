class Person < ActiveRecord::Base
  has_many :person_roles, dependent: :destroy
  has_many :animes, -> { order :id }, through: :person_roles
  has_many :mangas, -> { order :id }, through: :person_roles
  has_many :characters, -> { order :id }, through: :person_roles

  has_many :images, -> { where owner_type: Person.name },
    class_name: AttachedImage.name,
    foreign_key: :owner_id,
    dependent: :destroy

  has_attached_file :image,
    styles: {
      original: ['225x350>', :jpg],
      preview: ['80x120>', :jpg],
      x64: ['43x64#', :jpg]
    },
    url: "/images/person/:style/:id.:extension",
    path: ":rails_root/public/images/person/:style/:id.:extension",
    default_url: '/assets/globals/missing_:style.jpg'

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  has_one :thread, -> { where linked_type: Character.name },
    class_name: CharacterComment.name,
    foreign_key: :linked_id,
    dependent: :destroy

  after_create :create_thread
  after_save :sync_thread

  SeyuRoles = %w{ English Italian Hungarian Japanese German Hebrew Brazilian French Spanish Korean }
  MangakaRoles = ['Original Creator', 'Story & Art', 'Story', 'Art']

  # является ли человек режиссёром
  def producer?(role)
    role.include?('Director')
  end

  def to_param
    "%d-%s" % [id, name.gsub(/[^\w]+/, '-').gsub(/^-|-$/, '')]
  end

  def russian
    nil
  end

  def source
    nil
  end

  # при сохранении аниме обновление его CommentEntry
  def sync_thread
    if self.changes["name"]
      thread.sync
      thread.save
    end
  end
end
