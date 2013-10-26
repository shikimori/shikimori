class Video < ActiveRecord::Base
  belongs_to :anime
  belongs_to :uploader, class_name: User.name

  validates_presence_of :anime_id
  validates_presence_of :uploader_id
  validates_presence_of :url
  validates_presence_of :kind

  before_create :existence
  before_create :youtube
  after_create :suggest_acception

  PV = 'PV'
  OP = 'OP'
  ED = 'ED'
  AMW = 'AMW'
  OST = 'OST'

  PARAM_REGEXP = /(?:&|\?)v=(.*?)(?:&|$)/

  default_scope order('kind desc, name')

  state_machine :state, initial: :uploaded do
    state :uploaded, :confirmed do
      validates_uniqueness_of :url, case_sensitive: true, scope: [:anime_id, :state]
      validate :existence
      validate :youtube
    end
    state :deleted

    event :confirm do
      transition uploaded: :confirmed
    end
    event :del do
      transition [:uploaded, :confirmed] => :deleted
    end
  end

  def image_url
    "http://img.youtube.com/vi/#{key}/mqdefault.jpg"
  end

  def direct_url
    url.sub /watch\?v=/, 'v/'
  end

  def key
    url.match(PARAM_REGEXP) ? $1 : nil
  end

  # напреление видео на удаление
  def suggest_deletion(user)
    return unless confirmed?

    UserChange.create({
      action: UserChange::VideoDeletion,
      column: 'video',
      item_id: anime_id,
      model: Anime.name,
      user_id: user.id,
      value: id
    })
  end

  def url=(url)
    self[:url] = url || ''
    self[:url] = self[:url].sub(/^https/, 'http').sub(/#.*/, '').sub(/^http:\/\/www\./, 'http://')

    if self[:url].starts_with?('http://youtube.com/watch?') && self.url =~ PARAM_REGEXP
      self[:url] = 'http://youtube.com/watch?v=' + $1
    end
  end

private
  def youtube
    unless (url || '').starts_with?('http://youtube.com/watch?') && url =~ PARAM_REGEXP
      self.errors[:url] = 'некорректен, должна быть ссылка на youtube'
      false
    end
  end

  def existence
    sleep 1 # задержка, т.к. ютуб блочит при быстрых запросах
    open("http://gdata.youtube.com/feeds/api/videos/#{key}").read
  rescue OpenURI::HTTPError
    self.errors[:url] = 'некорректен, нет такого видео на youtube'
    false
  end

  # направление видео на модерацию
  def suggest_acception
    UserChange.create({
      action: UserChange::VideoUpload,
      column: 'video',
      item_id: anime_id,
      model: Anime.name,
      user_id: uploader_id,
      value: id,
      status: uploaded? ? UserChangeStatus::Pending : UserChangeStatus::Taken
    })
  end
end
