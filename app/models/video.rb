class Video < ActiveRecord::Base
  extend Enumerize
  SAVEABLE_HOSTINGS = [:youtube, :vk, :rutube, :sibnet, :dailymotion]

  belongs_to :anime
  belongs_to :uploader, class_name: User.name

  enumerize :hosting, in: [:youtube, :vk, :coub, :twitch, :rutube, :vimeo, :myvi, :sibnet, :yandex, :dailymotion], predicates: true

  validates :anime_id, :uploader_id, :url, :kind, presence: true
  validates_uniqueness_of :url, case_sensitive: true, scope: [:anime_id, :state]

  before_create :check_url
  before_create :check_hosting
  after_create :suggest_acception

  scope :youtube, -> { where hosting: :youtube }

  PV = 'PV'
  OP = 'OP'
  ED = 'ED'
  AMW = 'AMW'
  OST = 'OST'

  YOUTUBE_PARAM_REGEXP = /(?:&|\?)v=(.*?)(?:&|$)/
  VK_PARAM_REGEXP = %r{https?://vk.com/video-?(\d+)_(\d+)}

  default_scope -> { order 'kind desc, name' }

  state_machine :state, initial: :uploaded do
    state :uploaded do

    end
    state :confirmed
    state :deleted

    event :confirm do
      transition uploaded: :confirmed
    end
    event :del do
      transition [:uploaded, :confirmed] => :deleted
    end
  end

  def url= url
    return if url.nil?
    self[:url] = url.sub(/^https/, 'http').sub(/^http:\/\/www\./, 'http://')

    data = VideoExtractor.fetch self[:url]
    if data
      self.hosting = data.hosting
      self.image_url = data.image_url
      self.player_url = data.player_url
    end

    self[:url]
  end

  # напреление видео на удаление
  def suggest_deletion user
    return unless confirmed?

    UserChange.create(
      action: UserChange::VideoDeletion,
      column: 'video',
      item_id: anime_id,
      model: Anime.name,
      user_id: user.id,
      value: id
    )
  end

private
  def check_url
    if hosting.present?
      true
    else
      self.errors[:url] = I18n.t 'activerecord.errors.models.videos.attributes.url.incorrect'
      false
    end
  end

  def check_hosting
    if SAVEABLE_HOSTINGS.include? hosting.to_sym
      true
    else
      self.errors[:url] = I18n.t 'activerecord.errors.models.videos.attributes.hosting.incorrect'
      false
    end
  end

  # направление видео на модерацию
  def suggest_acception
    UserChange.create(
      action: UserChange::VideoUpload,
      column: 'video',
      item_id: anime_id,
      model: Anime.name,
      user_id: uploader_id,
      value: id,
      status: uploaded? ? UserChangeStatus::Pending : UserChangeStatus::Taken
    )
  end
end
