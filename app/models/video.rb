class Video < ActiveRecord::Base
  extend Enumerize

  belongs_to :anime
  belongs_to :uploader, class_name: User.name

  serialize :details

  validates :anime_id, presence: true
  validates :uploader_id, presence: true
  validates :url, presence: true
  validates :kind, presence: true

  validates_uniqueness_of :url, case_sensitive: true, scope: [:anime_id, :state]

  before_create :check_url
  before_create :check_youtube_existence, if: :youtube?
  before_create :check_vk_existence, if: :vk?

  after_create :suggest_acception

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

  def image_url
    if youtube?
      "http://img.youtube.com/vi/#{key}/mqdefault.jpg"
    else
      details[:image_url]
    end
  end

  def direct_url
    if youtube?
      url.sub /watch\?v=/, 'v/'
    else
      "https://vk.com/video_ext.php?oid=#{details.oid}&id=#{details.vid}&hash=#{details.hash2}&hd=1"
    end
  end

  def key
    url.match(YOUTUBE_PARAM_REGEXP) ? $1 : nil
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

  def url= url
    self[:url] = url || ''
    self[:url] = self[:url].sub(/^https/, 'http').sub(/#.*/, '').sub(/^http:\/\/www\./, 'http://')

    if self[:url].starts_with?('http://youtube.com/watch?') && self.url =~ YOUTUBE_PARAM_REGEXP
      self[:url] = 'http://youtube.com/watch?v=' + $1
    end

    url
  end

  def youtube?
    !!(url && url.starts_with?('http://youtube.com/watch?'))
  end

  def vk?
    !!(url && url.starts_with?('http://vk.com/video'))
  end

  def details
    self[:details] || fetch_vk_details if vk?
  end

  def hosting
    vk? ? :vk : :youtube
  end

private
  def check_url
    return if (youtube? && url =~ YOUTUBE_PARAM_REGEXP) || (vk? && url =~ VK_PARAM_REGEXP)

    self.errors[:url] = I18n.t('activerecord.errors.models.videos.attributes.url.incorrect')
    false
  end

  def check_youtube_existence
    sleep 1 unless Rails.env.test? # задержка, т.к. ютуб блочит при быстрых запросах
    open("http://gdata.youtube.com/feeds/api/videos/#{key}").read

  rescue OpenURI::HTTPError
    self.errors[:url] = I18n.t('activerecord.errors.models.videos.attributes.url.youtube_not_exist')
    false
  end

  def check_vk_existence
    if details.nil?
      self.errors[:url] = I18n.t('activerecord.errors.models.videos.attributes.url.vk_not_exist')
      false
    else
      details
    end
  end

  def fetch_vk_details
    sleep 1 unless Rails.env.test?
    self.details = VkVideoExtractor.new(url).fetch
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
