class Character < ActiveRecord::Base
  has_many :person_roles,
           :dependent => :destroy
  has_many :animes, :through => :person_roles,
                    :order => :id
  has_many :mangas, :through => :person_roles,
                    :order => :id
  has_many :persons, :through => :person_roles

  has_many :japanese_roles, :class_name => 'PersonRole',
                            :conditions => { :role => 'Japanese' }
  has_many :seyu, :through => :japanese_roles,
                  :source => :person

  has_many :images, :class_name => AttachedImage.name,
                    :foreign_key => :owner_id,
                    :conditions => {:owner_type => Character.name},
                    :dependent => :destroy

  has_attached_file :image, :styles => {
                      :preview => "80x120>",
                      :x96 => "64x96#",
                      :x64 => "43x64#"
                    },
                    :url  => "/images/character/:style/:id.:extension",
                    :path => ":rails_root/public/images/character/:style/:id.:extension",
                    :default_url => '/assets/globals/missing_:style.jpg'

  has_one :thread, :class_name => CharacterComment.name,
                   :foreign_key => :linked_id,
                   :conditions => {:linked_type => Character.name},
                   :dependent => :destroy

  has_many :cosplay_gallery_links, :as => :linked,
                                   :dependent => :destroy

  has_many :cosplay_galleries, :through => :cosplay_gallery_links,
                               :class_name => CosplaySession.name,
                               :conditions => { :deleted => false, confirmed: true }

  after_create :create_thread
  after_save :sync_thread

  before_save -> {
    self.russian = CGI::escapeHTML self.russian if self.changes['russian']
  }

  # Methods
  def to_param
    "%d-%s" % [id, name.gsub(/&#\d{4};/, '-').gsub(/[^A-z0-9]+/, '-').gsub(/^-|-$/, '')]
  end

  # создание CharacterComment для элемента сразу после создания
  def create_thread
    CharacterComment.create! linked: self, generated: true, title: name
  end

  # при сохранении аниме обновление его CommentEntry
  def sync_thread
    if self.changes["name"]
      thread.sync
      thread.save
    end
  end

  # альтернативное имя "в кавычках"
  def altname
    fullname.present? ? fullname.gsub(/^.*?"|".*?$/, '') : nil
  end
end
