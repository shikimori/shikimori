class DbEntry < ActiveRecord::Base
  self.abstract_class = true
  SIGNIFICANT_FIELDS = %w{name genres}

  def self.inherited klass
    super

    klass.has_one :thread, -> { where linked_type: klass.name },
      class_name: Topics::EntryTopic,
      foreign_key: :linked_id,
      dependent: :destroy

    klass.has_many :club_links, -> { where linked_type: klass.name },
      foreign_key: :linked_id,
      dependent: :destroy

    klass.has_many :clubs, through: :club_links

    klass.after_create :generate_thread
    # klass.after_save :sync_thread
    #klass.before_save :filter_russian, if: -> { changes['russian'] }
  end

  def to_param
    # change ids to new ones because of google bans
    changed_id = CopyrightedIds.instance.change id, self.class.name.downcase
    "#{changed_id}-#{name.permalinked}"
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
    Topics::EntryTopic.wo_timestamp do
      #TODO: title должен генериться автоматически и локализовываться
      # в зависимости от нстроек пользователя
      create_thread!(
        linked: self,
        generated: true,
        title: name,
        created_at: created_at
      )
    end
  end

  # при сохранении аниме обновление его топика
  # def sync_thread
    # return unless changes['name']

    # thread.class.wo_timestamp do
      # thread.sync
      # thread.save
    # end
  # end

  #def filter_russian
    #self.russian = CGI::escapeHTML russian
  #end
end
