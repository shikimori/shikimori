class DbEntry < ActiveRecord::Base
  self.abstract_class = true
  SIGNIFICANT_FIELDS = %w{name genres image}

  def self.inherited klass
    super

    klass.has_one :topic, -> { where linked_type: klass.name },
      class_name: "Topics::EntryTopics::#{klass.name}Topic",
      foreign_key: :linked_id,
      dependent: :destroy

    klass.has_many :club_links, -> { where linked_type: klass.name },
      foreign_key: :linked_id,
      dependent: :destroy

    klass.has_many :clubs, through: :club_links

    klass.after_create :generate_topic
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

  def generate_topic
    Topics::Generate::SiteTopic.call self, BotsService.get_poster
  end
end
