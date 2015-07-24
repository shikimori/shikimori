class DbEntry < ActiveRecord::Base
  self.abstract_class = true

  def self.inherited klass
    super

    klass.has_one :thread, -> { where linked_type: klass.name },
      class_name: klass.thread_klass.name,
      foreign_key: :linked_id,
      dependent: :destroy

    klass.has_many :group_links, -> { where linked_type: klass.name },
      foreign_key: :linked_id,
      dependent: :destroy

    klass.has_many :groups, through: :group_links

    klass.after_create :generate_thread
    klass.after_save :sync_thread
    #klass.before_save :filter_russian, if: -> { changes['russian'] }
  end

  def to_param
    "#{id}-#{name.permalinked}"
  end

  # аниме ли это?
  def anime?
    self.class == Anime
  end

  # манга ли это?
  def manga?
    self.class == Manga
  end

private

  # создание топика для элемента сразу после создания элемента
  def generate_thread
    create_thread! linked: self, generated: true, title: name
  end

  # при сохранении аниме обновление его топика
  def sync_thread
    if self.changes['name']
      thread.class.record_timestamps = false
      thread.sync
      thread.save
      thread.class.record_timestamps = true
    end
  end

  #def filter_russian
    #self.russian = CGI::escapeHTML russian
  #end

  def self.thread_klass
    if self == Anime || self == Manga
      AniMangaComment
    #elsif self == Seyu
      #PersonComment
    else
      "#{self.name}Comment".constantize
    end
  end
end
