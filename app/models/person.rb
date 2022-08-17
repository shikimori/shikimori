class Person < DbEntry
  include ClubsConcern
  include CollectionsConcern
  include ContestsConcern
  include FavouritesConcern
  include TopicsConcern
  include VersionsConcern

  DESYNCABLE = %w[name japanese website birth_on image]

  update_index('people#person') do
    if saved_change_to_name? || saved_change_to_russian? ||
        saved_change_to_japanese? || saved_change_to_is_seyu? ||
        saved_change_to_is_producer? || saved_change_to_is_mangaka?
      self
    end
  end

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
    convert_options: {
      original: '-quality 95',
      preview: '-quality 90',
      x96: '-quality 86',
      x48: '-quality 86'
    },
    url: '/system/people/:style/:id.:extension',
    path: ':rails_root/public/system/people/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style.jpg'

  before_post_process { translit_paperclip_file_name :image }

  boolean_attributes :producer, :mangaka, :seyu

  validates :image, attachment_content_type: { content_type: /\Aimage/ }
  validates :name, :japanese, length: { maximum: 255 }

  attribute :birth_on_v2, IncompleteDate

  SEYU_ROLES = %w[
    English Italian Hungarian Japanese German Hebrew Brazilian French
    Spanish Korean Hebrew Mandarin
  ]
  MANGAKA_ROLES = ['Original Creator', 'Story & Art', 'Story', 'Art']

  def mal_url
    return unless mal_id

    "http://myanimelist.net/people/#{mal_id}"
  end
end
