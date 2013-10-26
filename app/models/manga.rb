# TODO: переделать kind в enumerize (https://github.com/brainspec/enumerize)
class Manga < ActiveRecord::Base
  include AniManga
  EXCLUDED_ONGOINGS = [-1]
  Duration = 8

  serialize :english
  serialize :japanese
  serialize :synonyms
  serialize :mal_scores
  #serialize :ani_db_scores
  #serialize :world_art_scores

  # Relations
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :publishers

  has_many :person_roles, :dependent => :destroy
  has_many :characters, :through => :person_roles
  has_many :people, :through => :person_roles

  has_many :rates, :class_name => UserRate.name,
                   :foreign_key => :target_id,
                   :conditions => {:target_type => self.name},
                   :dependent => :destroy

  has_many :related, :dependent => :destroy,
                     :foreign_key => :source_id,
                     :class_name => RelatedManga.name
  has_many :related_mangas, :through => :related,
                            :foreign_key => :source_id,
                            :conditions => 'manga_id is not null'
  has_many :related_animes, :through => :related,
                            :foreign_key => :source_id,
                            :conditions => 'anime_id is not null'

  has_many :topics, :class_name => Entry.name,
                    :order => ' updated_at desc',
                    :as => :linked,
                    :dependent => :destroy

  has_many :news, :class_name => MangaNews.name,
                  :as => :linked,
                  :order => 'created_at desc'

  has_many :similar, :class_name => SimilarManga.name,
                     :foreign_key => :src_id,
                     :order => 'id desc',
                     :dependent => :destroy

  has_many :user_histories, :foreign_key => :target_id,
                            :conditions => { :target_type => Manga.name },
                            :dependent => :destroy

  has_many :cosplay_gallery_links, :as => :linked,
                                   :dependent => :destroy

  has_many :cosplay_galleries, :through => :cosplay_gallery_links,
                               :class_name => CosplaySession.name,
                               :conditions => { :deleted => false, confirmed: true }

  has_one :thread, :class_name => AniMangaComment.name,
                    :foreign_key => :linked_id,
                    :conditions => {:linked_type => self.name},
                    :dependent => :destroy

  has_many :reviews, :foreign_key => :target_id,
                     :conditions => {:target_type => self.name},
                     :dependent => :destroy

  has_many :images, :class_name => AttachedImage.name,
                    :foreign_key => :owner_id,
                    :conditions => {:owner_type => self.name},
                    :dependent => :destroy

  has_many :recommendation_ignores, :conditions => { target_type: Anime.name },
                                    :foreign_key => :target_id,
                                    :dependent => :destroy

  has_attached_file :image, :styles => { :preview => "160x240>", :x96 => "64x96#", :x64 => "43x64#" }, # params: > #
                            #:processors => [:time_stamper],
                            :url  => "/images/manga/:style/:id.:extension",
                            :path => ":rails_root/public/images/manga/:style/:id.:extension"
  validates_attachment_content_type :image, :content_type => [/^image\/(?:jpeg)$/, nil]

  # Hooks
  after_create :create_thread
  after_save :sync_thread

  def name
    self[:name] ? self[:name].gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip.html_safe : nil
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
  def manga?
    kind == 'Manga' || kind == 'Manhwa' || kind == 'Manhua'
  end
end
