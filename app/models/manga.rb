# frozen_string_literal: true

class Manga < DbEntry
  include AniManga
  include TopicsConcern
  include CollectionsConcern
  include ElasticsearchConcern

  EXCLUDED_ONGOINGS = [-1]

  DESYNCABLE = %w(
    name kind volumes chapters aired_on released_on status genres
    description_en image external_links
  )
  CHAPTER_DURATION = 8
  VOLUME_DURATION = (24 * 60) / 20 # 20 volumes per day

  serialize :synonyms
  #serialize :ani_db_scores
  #serialize :world_art_scores

  attr_accessor :in_list

  # Relations
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :publishers

  has_many :person_roles, dependent: :destroy
  has_many :characters, through: :person_roles
  has_many :people, through: :person_roles

  has_many :rates, -> { where target_type: Manga.name },
    class_name: UserRate.name,
    foreign_key: :target_id,
    dependent: :destroy

  has_many :related,
    class_name: RelatedManga.name,
    foreign_key: :source_id,
    dependent: :destroy
  has_many :related_animes, -> { where.not related_mangas: { anime_id: nil } },
    through: :related,
    source: :anime
  has_many :related_mangas, -> { where.not related_mangas: { manga_id: nil } },
    through: :related,
    source: :manga

  has_many :similar, -> { order :id },
    class_name: SimilarManga.name,
    foreign_key: :src_id,
    dependent: :destroy
  has_many :similar_mangas,
    through: :similar,
    source: :dst

  has_many :user_histories, -> { where target_type: Manga.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy

  has_many :cosplay_galleries, -> { where deleted: false, confirmed: true },
    through: :cosplay_gallery_links

  has_many :reviews, -> { where target_type: Manga.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :recommendation_ignores, -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :manga_chapters, class_name: MangaChapter.name, dependent: :destroy

  has_many :name_matches, -> { where target_type: Manga.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_attached_file :image,
    styles: {
      original: ['225x350>', :jpg],
      preview: ['160x240>', :jpg],
      x96: ['96x150#', :jpg],
      x48: ['48x75#', :jpg]
    },
    url: '/system/mangas/:style/:id.:extension',
    path: ':rails_root/public/system/mangas/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style.jpg'

  before_post_process { translit_paperclip_file_name :image }

  has_many :external_links, -> { order :id },
    class_name: ExternalLink.name,
    as: :entry,
    inverse_of: :entry,
    dependent: :destroy
  has_one :anidb_external_link,
    -> { where(kind: Types::ExternalLink::Kind[:anime_db]) },
    class_name: ExternalLink.name,
    as: :entry,
    inverse_of: :entry

  enumerize :type, in: %i[Manga Ranobe]
  enumerize :kind,
    in: %i[manga manhwa manhua novel one_shot doujin],
    predicates: { prefix: true }
  enumerize :status, in: %i[anons ongoing released], predicates: true

  validates :name, presence: true
  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  scope :read_manga, -> { where('read_manga_id like ?', 'rm_%') }
  scope :read_manga_adult, -> { where('read_manga_id like ?', 'am_%') }

  before_create :set_type
  before_save :set_type, if: -> { kind_changed? }
  after_create :generate_name_matches

  def name
    self[:name].gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip if self[:name].present?
  end

  def volumes= value
    value.blank? ? super(0) : super(value)
  end

  def chapters= value
    value.blank? ? super(0) : super(value)
  end

  # имя сайта ридманги
  def read_manga_name
    read_manga_id.starts_with?(ReadMangaImporter::Prefix) ? 'ReadManga' : 'AdultManga'
  end

  # url сайта ридманги
  def read_manga_url
    read_manga_id.starts_with?(ReadMangaImporter::Prefix) ?
      "http://readmanga.ru/#{read_manga_id.sub(ReadMangaImporter::Prefix, '')}" :
      "http://adultmanga.ru/#{read_manga_id.sub(AdultMangaImporter::Prefix, '')}"
  end

  def duration
    Manga::DURATION
  end

private

  def set_type
    self.type = kind_novel? ? Ranobe.name : Manga.name
  end
end
