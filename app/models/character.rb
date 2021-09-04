# frozen_string_literal: true

class Character < DbEntry
  include ClubsConcern
  include CollectionsConcern
  include ContestsConcern
  include FavouritesConcern
  include TopicsConcern
  include VersionsConcern

  DESYNCABLE = %w[name japanese description_en image]

  update_index('characters#character') do
    if saved_change_to_name? || saved_change_to_russian? ||
        saved_change_to_fullname? || saved_change_to_japanese?
      self
    end
  end

  has_many :person_roles, dependent: :destroy
  has_many :animes, -> { order :id }, through: :person_roles
  has_many :mangas, -> { order :id }, through: :person_roles
  has_many :people, through: :person_roles

  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy
  has_many :cosplay_galleries, -> { where deleted: false, confirmed: true },
    through: :cosplay_gallery_links

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
    url: '/system/characters/:style/:id.:extension',
    path: ':rails_root/public/system/characters/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style.jpg'

  before_post_process { translit_paperclip_file_name :image }

  validates :image, attachment_content_type: { content_type: /\Aimage/ }
  validates :description_ru, :description_en, length: { maximum: 32_768 }
  validates :name, :japanese, :fullname, length: { maximum: 255 }

  # альтернативное имя "в кавычках"
  def altname
    fullname.present? ? fullname.gsub(/^.*?"|".*?$/, '') : nil
  end

  def rkn_abused?
    Copyright::ABUSED_BY_RKN_CHARACTER_IDS.include? id
  end

  def image_file_name
    rkn_abused? ? nil : super
  end
end
