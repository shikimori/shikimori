# TODO: переделать kind в enumerize (https://github.com/brainspec/enumerize)
class Manga < DbEntry
  include AniManga
  EXCLUDED_ONGOINGS = [-1]

  CHAPTER_DURATION = 8
  VOLUME_DURATION = (24 * 60) / 20 # 20 volumes per day

  serialize :english
  serialize :japanese
  serialize :synonyms
  serialize :mal_scores
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

  has_many :topics, -> { order updated_at: :desc },
    class_name: Entry.name,
    as: :linked,
    dependent: :destroy

  has_many :news, -> { order created_at: :desc },
    class_name: MangaNews.name,
    as: :linked

  has_many :similar, -> { order id: :desc },
    class_name: SimilarManga.name,
    foreign_key: :src_id,
    dependent: :destroy

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

  has_attached_file :image,
    styles: {
      original: ['225x350>', :jpg],
      preview: ['160x240>', :jpg],
      x96: ['96x150#', :jpg],
      x48: ['48x75#', :jpg]
    },
    url: "/images/manga/:style/:id.:extension",
    path: ":rails_root/public/images/manga/:style/:id.:extension",
    default_url: '/assets/globals/missing_:style.jpg'

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  scope :read_manga, -> { where('read_manga_id like ?', 'rm_%') }
  scope :read_manga_adult, -> { where('read_manga_id like ?', 'am_%') }

  def name
    self[:name].gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip if self[:name].present?
  end

  # тип манги на русском
  def russian_kind
    kind == 'Novel' ? 'Новелла' : 'Манга'
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

  # манга ли это?
  #def manga?
    #kind == 'Manga' || kind == 'Manhwa' || kind == 'Manhua'
  #end

  def duration
    Manga::DURATION
  end
end
