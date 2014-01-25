class Entry < ActiveRecord::Base
  include PermissionsPolicy
  include Commentable
  include Viewable

  attr_protected :user_id

  belongs_to :section
  belongs_to :linked, polymorphic: true
  belongs_to :user

  validates :section, presence: true unless Rails.env.test?

  has_many :messages,
    foreign_key: :linked_id,
    conditions: proc { "linked_type = '#{self.class.name}' or linked_type = '#{Entry.name}'" },
    dependent: :destroy

  before_save :validates_linked
  before_save :append_wall
  before_update :unclaim_images
  before_destroy :destroy_images
  after_save :claim_images

  # классы, которые не отображаются на общем форуме, пока у них нет комментарив
  SpecialTypes = ['AnimeNews', 'MangaNews', 'AniMangaComment', 'CharacterComment', 'GroupComment']

  # классы, которые не отображаются на внутреннем форуме, пока у них нет комментарив
  SpecialInnerTypes = ['AnimeNews', 'MangaNews']

  # все производные классы
  Types = ['Entry', 'Topic', 'AniMangaComment', 'CharacterComment', 'GroupComment', 'ReviewComment', 'ContestComment']

  # видимые топики
  scope :wo_generated, where { action.not_eq(AnimeHistoryAction::Episode) | action.eq(nil) }.
                       where { (comments_count.gt(0) & generated.eq(true)) | generated.eq(false) }
  # топики без топиков о выходе эпизодов
  scope :wo_episodes, where { action.not_eq(AnimeHistoryAction::Episode) }

  #scope :visible_only, where { (comments_count.gt(0) & type.in(Entry::SpecialTypes)) | type.in(Types - SpecialTypes) }.wo_generated # not_in не использовать!!! пойдёт не по индексу
  scope :order_default, order { updated_at.desc }

  def to_param
    "%d-%s" % [id, permalink]
  end

  def cache_key
    "#{super}-#{Digest::MD5.hexdigest(body || '')}"
  end

  def year
    created_at.year
  end

  def month
    "%02d" % created_at.month
  end

  def day
    "%02d" % created_at.day
  end

  # базовый класс для комментариев
  def base_class
    Entry
  end

  def body
    text
  end

  # специальный ли тип топика?
  def special?
    SpecialTypes.include? self.class.name
  end

  # пометить комментарий топика как прочтенный, если есть уведомления о непрочтённых сообщениях, помечаем их тоже
  #def mark_as_viewed(user_id, comment)
    #entry_view = EntryView.find_or_create_by_user_id_and_entry_id(user_id: user_id,
                                                                  #entry_id: self.id,
                                                                  #comment_id: 0)
    #if (entry_view.comment_id || 0) < (comment ? comment.id : 0)
      #ActiveRecord::Base.connection.
        #execute("
                 #update `messages`
                   #set `read`=1
                   #where
                     #`dst_id` = #{user_id}
                     #and `dst_type`='#{User.name}'
                     #and `read`=0
                     #and `kind` in ('#{MessageType::SubscriptionCommented}', '#{MessageType::QuotedByUser}')
                     #and `linked_id`=#{self.id}
                     #and `linked_type`='#{self.class.name}'
                #")

      #entry_view.comment_id = comment ? comment.id : 0
      #entry_view.save
    #end
  #end

  # прочтен ли топик?
  def viewed?
    generated? ? true : super
  end

  # колбек, срабатываемый при добавлении коммента
  def comment_added(comment)
    self.updated_at = Time.now
    self.created_at = self.updated_at if self.comments_count == 1
    self.save
    #self.mark_as_viewed(comment.user_id, comment)
  end

  # колбек, срабатываемый при удалении коммента
  def comment_deleted(comment)
    #if self.comments.count == 0 && self.class == Topic
      #self.destroy
      #return {notice: 'Удалено', url_object: self.section}
    #else
      self.class.record_timestamps = false
      # self.comments.first - самый последний комментарий
      self.update_attributes(updated_at: self.comments.count > 0 ? self.comments.first.created_at : self.created_at,
                             comments_count: self.comments.count)
      self.class.record_timestamps = true
    #end
  end

  def title=(value)
    super value
    self.permalink = self.to_s.permalinked if value.present?
    value
  end

  def to_s
    self.title
  end

  # идентификатор для рсс ленты
  def guid
    "entry-#{self.id}"
  end

  # оффтопик ли это? для совместимости с интерфейсом отображения комментариев
  def offtopic?
    false
  end

  # сгенерированный ли топик
  def generated?
    generated
  end

  # новостной ли это топиик?
  def news?
    !!(self.class.name =~ /News/)
  end

  # топик ли это обзора?
  def review?
    self.class == ReviewComment
  end

  def user_image_ids(value=self.value)
    (value || '').split(',').map(&:to_i).select { |v| v > 0 }
  end

  def user_image_ids=(ids)
    self.value = ids.join(',')
  end

  # картинки, загруженные пользователями в топик
  def user_images
    ids = user_image_ids
    if ids.any?
      UserImage.where(id: ids)
          .all
          .sort_by {|v| ids.index v.id }
    else
      []
    end
  end

  # оригинальный текст без сгенерированных автоматом тегов
  def original_text
    (text || '').sub(/[\n\r]*\[wall[\s\S]*/, '')
  end

private
  # проверка, что linked при его наличии нужного типа
  def validates_linked
    return unless self[:linked_type].present? && self[:linked_type] !~ /^(Anime|Manga|Character|Group|Review|Contest)$/
    errors[:linked_type] = 'Forbidden Linked Type'
    return false
  end

  # дописывание к тексту топика картинок
  def append_wall
    return if generated?
    images = user_images

    if images.any?
      self.text = self.text.sub(/\[wall[\s\S]*/, '') + "\n[wall]" + images.map do |image|
        "[url=#{image.image.url :original, false}][img]#{image.image.url :preview, false}[/img][/url]"
      end.join('') + "[/wall]"
    end
  end

  # пометка картинок на принадлежность текущему топику
  def claim_images
    UserImage
      .where(id: user_image_ids, linked_id: nil, linked_type: self.class.name)
      .update_all(linked_id: id, linked_type: self.class.name)
  end

  # удаление более неиспользуемых картинок
  def unclaim_images
    if changes['value'].present? && !generated?
      unused_ids = user_image_ids(changes['value'][0]) - user_image_ids

      UserImage.where(id: unused_ids, linked_id: id, linked_type: self.class.name).destroy_all
    end
  end

  # полное удаление всех картинок
  def destroy_images
    user_images
      .select {|v| v.linked_id == id && v.linked_type == self.class.name }
      .each(&:destroy)
  end
end
