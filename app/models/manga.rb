# frozen_string_literal: true

class Manga < DbEntry
  include AniManga
  include TopicsConcern
  include CollectionsConcern
  include VersionsConcern
  include ClubsConcern
  include ContestsConcern
  include FavouritesConcern

  EXCLUDED_ONGOINGS = [-1]

  DESYNCABLE = %w[
    name japanese synonyms kind volumes chapters aired_on released_on status
    genre_ids description_en image external_links is_censored
  ]
  CHAPTER_DURATION = 8
  VOLUME_DURATION = (24 * 60) / 20 # 20 volumes per day

  update_index('mangas#manga') do
    if saved_change_to_name? || saved_change_to_russian? ||
        saved_change_to_english? || saved_change_to_japanese? ||
        saved_change_to_synonyms? || saved_change_to_score? ||
        saved_change_to_kind?
      self
    end
  end

  update_index('licensors#licensor') do
    if saved_change_to_licensors?
      added = licensors
        .map { |v| { id: v, kind: 'manga' } }
      deleted = (previous_changes['licensors'][0] - previous_changes['licensors'][1])
        .select { |v| Manga.where("licensors && '{#{Manga.sanitize v, true}}'").none? }
        .map { |v| { id: v, kind: 'manga', _destroyed: true } }

      added + deleted
    end
  end

  # update_index('licensors#licensor') do
  #   if saved_change_to_licensors?
  #     added = licensors.map { |v| OpenStruct.new id: v, kind: 'manga' }
  #     deleted = previous_changes['licensors'][0] - previous_changes['licensors'][1]
  #
  #     added + deleted
  #   end
  # end

  attr_accessor :in_list

  # relations
  has_many :person_roles, dependent: :destroy
  has_many :characters, through: :person_roles
  has_many :people, through: :person_roles

  has_many :rates, -> { where target_type: Manga.name },
    class_name: UserRate.name,
    foreign_key: :target_id,
    dependent: :destroy
  has_many :user_rate_logs, -> { where target_type: Manga.name },
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

  has_many :reviews, dependent: :destroy, inverse_of: :manga

  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy

  has_many :cosplay_galleries, -> { where deleted: false, confirmed: true },
    through: :cosplay_gallery_links

  has_many :critiques, -> { where target_type: Manga.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :recommendation_ignores, -> { where target_type: Manga.name },
    foreign_key: :target_id,
    dependent: :destroy

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
    convert_options: {
      original: '-quality 95',
      preview: '-quality 90',
      x96: '-quality 86',
      x48: '-quality 86'
    },
    url: '/system/mangas/:style/:id.:extension',
    path: ':rails_root/public/system/mangas/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style.jpg'

  before_post_process { translit_paperclip_file_name :image }

  has_many :external_links, -> { where(source: :shikimori).order(:id) },
    class_name: ExternalLink.name,
    as: :entry,
    inverse_of: :entry
  has_many :all_external_links, -> { order :id },
    class_name: ExternalLink.name,
    as: :entry,
    inverse_of: :entry,
    dependent: :destroy
  has_one :anidb_external_link,
    -> { where(kind: Types::ExternalLink::Kind[:anime_db]) },
    class_name: ExternalLink.name,
    as: :entry,
    inverse_of: :entry
  has_one :readmanga_external_link,
    -> { where(kind: Types::ExternalLink::Kind[:readmanga]) },
    class_name: ExternalLink.name,
    as: :entry,
    inverse_of: :entry

  enumerize :type, in: %i[Manga Ranobe]
  enumerize :kind,
    in: Types::Manga::Kind.values,
    predicates: { prefix: true }
  enumerize :status,
    in: Types::Manga::Status.values,
    predicates: true

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  before_save :set_type, if: -> { kind_changed? }
  before_create :set_type
  after_create :generate_name_matches

  def name
    if self[:name].present?
      self[:name].gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip
    end
  end

  def genres
    @genres ||= MangaGenresRepository.find genre_ids
  end

  def publishers
    @publishers ||= PublishersRepository.find publisher_ids
  end

  def volumes= value
    value.blank? ? super(0) : super(value)
  end

  def chapters= value
    value.blank? ? super(0) : super(value)
  end

  # def duration
  #   Manga::DURATION
  # end

  def forbidden?
    false
  end

  def censored?
    is_censored || rkn_abused?
  end

  def rkn_abused?
    Copyright::ABUSED_BY_RKN_MANGA_IDS.include? id
  end

  def rkn_banned?
    Copyright::BANNED_BY_RKN_MANGA_IDS.include? id
  end

private

  def set_type
    self.type = (kind_novel? || kind_light_novel?) ?
      Ranobe.name :
      Manga.name
  end
end
