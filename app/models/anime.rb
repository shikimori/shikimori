# frozen_string_literal: true

class Anime < DbEntry
  include AniManga
  include TopicsConcern
  include CollectionsConcern
  include VersionsConcern
  include ClubsConcern
  include ContestsConcern
  include FavouritesConcern
  include RknConcern

  DESYNCABLE = %w[
    name japanese synonyms kind episodes rating aired_on released_on status
    genre_ids genre_v2_ids duration description_en image poster external_links
    is_censored origin
  ]

  FORBIDDEN_ADULT_IDS = [
    # banned by roskomnadzor
    5042,
    7593,
    8861,
    6987,
    # hentai w/o Rx rating
    39_337
  ]

  update_index('animes#anime') do
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
        .map { |v| { id: v, kind: Types::Licensor::Kind[:anime] } }
      deleted = (previous_changes['licensors'][0] - previous_changes['licensors'][1])
        .select { |v| Anime.where("licensors && '{#{Anime.sanitize v, true}}'").none? }
        .map { |v| { id: v, kind: Types::Licensor::Kind[:anime], _destroyed: true } }

      added + deleted
    end
  end

  update_index('fansubbers#fansubber') do
    items = []

    if saved_change_to_fansubbers?
      added = fansubbers
        .map { |v| { id: v + '_fs', name: v, kind: Types::Fansubber::Kind[:fansubber] } }
      deleted = (previous_changes['fansubbers'][0] - previous_changes['fansubbers'][1])
        .select { |v| Anime.where("fansubbers && '{#{Anime.sanitize v, true}}'").none? }
        .map { |v| { id: v + '_fs', name: v, kind: Types::Fansubber::Kind[:fansubber], _destroyed: true } } # rubocop:disable Layout/LineLength

      items += added + deleted
    end

    if saved_change_to_fandubbers?
      added = fandubbers
        .map { |v| { id: v + '_fd', name: v, kind: Types::Fansubber::Kind[:fandubber] } }
      deleted = (previous_changes['fandubbers'][0] - previous_changes['fandubbers'][1])
        .select { |v| Anime.where("fandubbers && '{#{Anime.sanitize v, true}}'").none? }
        .map { |v| { id: v + '_fd', name: v, kind: Types::Fansubber::Kind[:fandubber], _destroyed: true } } # rubocop:disable Layout/LineLength

      items += added + deleted
    end

    items if items.any?
  end

  # relations
  has_one :poster, -> { active }, inverse_of: :anime # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :posters, dependent: :destroy

  has_many :person_roles, dependent: :destroy
  has_many :characters, through: :person_roles
  has_many :people, through: :person_roles

  has_many :rates,
    -> { where target_type: Anime.name },
    class_name: 'UserRate',
    foreign_key: :target_id,
    dependent: :destroy
  has_many :user_rate_logs, -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :user_histories, dependent: :destroy

  has_many :reviews, dependent: :destroy, inverse_of: :anime

  has_many :anons_news_topics,
    -> { where(action: AnimeHistoryAction::Anons).order(created_at: :desc) },
    class_name: 'Topics::NewsTopic',
    as: :linked

  has_many :episode_news_topics,
    -> { where(action: AnimeHistoryAction::Episode).order(created_at: :desc) },
    class_name: 'Topics::NewsTopic',
    as: :linked

  has_many :ongoing_news_topics,
    -> { where(action: AnimeHistoryAction::Ongoing).order(created_at: :desc) },
    class_name: 'Topics::NewsTopic',
    as: :linked

  has_many :released_news_topics,
    -> { where(action: AnimeHistoryAction::Released).order(created_at: :desc) },
    class_name: 'Topics::NewsTopic',
    as: :linked

  belongs_to :origin_manga,
    class_name: 'Manga',
    optional: true
  has_many :related,
    class_name: 'RelatedAnime',
    foreign_key: :source_id,
    dependent: :destroy
  has_many :related_animes, -> { where.not related_animes: { anime_id: nil } },
    through: :related,
    source: :anime
  has_many :related_mangas, -> { where.not related_animes: { manga_id: nil } },
    through: :related,
    source: :manga

  has_many :similar, -> { order :id },
    class_name: 'SimilarAnime',
    foreign_key: :src_id,
    dependent: :destroy
  has_many :similar_animes,
    through: :similar,
    source: :dst

  has_many :cosplay_gallery_links, as: :linked, dependent: :destroy
  has_many :cosplay_galleries,
    -> { where deleted: false, confirmed: true },
    through: :cosplay_gallery_links

  has_many :critiques, -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :screenshots, -> { where(status: nil).order(:position, :id) },
    inverse_of: :anime
  has_many :all_screenshots,
    class_name: 'Screenshot',
    dependent: :destroy

  has_many :videos, -> { where(state: 'confirmed') },
    inverse_of: :anime
  has_many :all_videos,
    class_name: 'Video',
    dependent: :destroy

  has_many :recommendation_ignores, -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :anime_calendars,
    -> { order :episode },
    dependent: :destroy

  has_many :anime_videos, dependent: :destroy
  has_many :episode_notifications, dependent: :destroy, inverse_of: :anime

  has_many :name_matches,
    -> { where target_type: Anime.name },
    foreign_key: :target_id,
    dependent: :destroy

  has_many :links,
    class_name: 'AnimeLink',
    dependent: :destroy

  has_many :external_links, -> { where(source: :shikimori).order(:id) },
    class_name: 'ExternalLink',
    as: :entry,
    inverse_of: :entry
  has_many :all_external_links, -> { order :id },
    class_name: 'ExternalLink',
    as: :entry,
    inverse_of: :entry,
    dependent: :destroy
  has_one :anidb_external_link,
    -> { where kind: Types::ExternalLink::Kind[:anime_db] },
    class_name: 'ExternalLink',
    as: :entry,
    inverse_of: :entry
  has_one :smotret_anime_external_link,
    -> { where kind: Types::ExternalLink::Kind[:smotret_anime] },
    class_name: 'ExternalLink',
    as: :entry,
    inverse_of: :entry

  has_many :anime_stat_histories,
    inverse_of: :anime,
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
    # convert_options: {
      # original: " -gravity center -crop '225x310+0+0'",
      # preview: " -gravity center -crop '160x220+0+0'"
    # },
    url: '/system/animes/:style/:id.:extension',
    path: ':rails_root/public/system/animes/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style.jpg'

  before_post_process { translit_paperclip_file_name :image }

  enumerize :kind,
    in: Types::Anime::Kind.values,
    predicates: { prefix: true }
  enumerize :origin,
    in: Types::Anime::Origin.values
  enumerize :status,
    in: Types::Anime::Status.values,
    predicates: true
  enumerize :rating,
    in: Types::Anime::Rating.values,
    predicates: { prefix: true }

  attribute :aired_on, IncompleteDate
  include IncompleteDate::ComputedField[:aired_on]
  attribute :released_on, IncompleteDate
  include IncompleteDate::ComputedField[:released_on]

  attribute :digital_released_on, IncompleteDate
  attribute :russia_released_on, IncompleteDate

  # enumerize :options,
  #   in: Types::Anime::Options.values,
  #   predicates: true,
  #   multiple: true,
  #   skip_validations: true

  validates :image, attachment_content_type: { content_type: /\Aimage/ }
  validates :season, length: { maximum: 255 }

  before_save :track_changes
  after_create :generate_name_matches
  after_save :generate_news, if: :saved_change_to_status?

  def episodes= value
    value.blank? ? super(0) : super
  end

  def latest?
    ongoing? || anons? || (aired_on.present? && aired_on > 1.year.ago)
  end

  def name
    if self[:name].present?
      self[:name].gsub(/é/, 'e').gsub(/ō/, 'o').gsub(/ä/, 'a').strip
    end
  end

  def genres
    @genres ||= AnimeGenresRepository.find genre_ids
  end

  def genres_v2
    @genres_v2 ||= AnimeGenresV2Repository.find(genre_v2_ids)
      .sort_by { |genre_v2| Types::GenreV2::KINDS.index genre_v2.kind.to_sym }
  end

  def studios
    @studios ||= StudiosRepository.find studio_ids
  end

  def torrents_name
    self[:torrents_name].presence
  end

  def broadcast_at
    return unless broadcast && (ongoing? || anons?)

    BroadcastDate.parse broadcast, aired_on&.date
  end

  # banned by roskomnadzor
  def forbidden?
    FORBIDDEN_ADULT_IDS.include? id
  end

private

  def track_changes
    Animes::TrackStatusChanges.call self
    Animes::TrackEpisodesChanges.call self
  end

  def generate_news
    Animes::GenerateNews.call self, *saved_changes[:status]
  end
end
