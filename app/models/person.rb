class Person < DbEntry
  DESYNCABLE = %w(name japanese website birthday image)

  has_many :person_roles, dependent: :destroy
  has_many :animes, -> { order :id }, through: :person_roles
  has_many :mangas, -> { order :id }, through: :person_roles
  has_many :characters, -> { order :id }, through: :person_roles

  has_attached_file :image,
    styles: {
      original: ['225x350>', :jpg],
      preview: ['160x240>', :jpg],
      x96: ['96x150#', :jpg],
      x48: ['48x75#', :jpg]
    },
    url: '/system/people/:style/:id.:extension',
    path: ':rails_root/public/system/people/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style.jpg'

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  SEYU_ROLES = %w(English Italian Hungarian Japanese German Hebrew Brazilian French Spanish Korean)
  MANGAKA_ROLES = ['Original Creator', 'Story & Art', 'Story', 'Art']

  # является ли человек режиссёром
  #def producer? role
    #role.include?('Director')
  #end

  def source
    nil
  end
end
