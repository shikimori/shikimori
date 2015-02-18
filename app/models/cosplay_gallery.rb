class CosplayGallery < ActiveRecord::Base
  #acts_as_voteable

  has_many :image, -> { where(deleted: false).limit(1) },
    class_name: 'CosplayImage'

  has_many :images, -> { where(deleted: false).order(:position) },
    class_name: 'CosplayImage',
    dependent: :destroy

  has_many :deleted_images, -> { where(deleted: true).order(:position) },
    class_name: 'CosplayImage'

  has_many :links, class_name: 'CosplayGalleryLink', dependent: :destroy
  has_many :cosplayers,
    through: :links,
    source: :linked,
    source_type: 'Cosplayer'

  has_many :animes,
    through: :links,
    source: :linked,
    source_type: 'Anime'

  has_many :mangas,
    through: :links,
    source: :linked,
    source_type: 'Manga'

  has_many :characters,
    through: :links,
    source: :linked,
    source_type: 'Character'

  accepts_nested_attributes_for :images, :deleted_images

  acts_as_taggable_on :tags

  def to_param
    "%d-%s" % [id, target.gsub(/&#\d{4};/, '-').gsub(/[^A-z0-9]+/, '-').gsub(/^-|-$/, '')]
  end

  # копирует все картинки в target, а текущую галерею помечает удалённой
  def move_to(target)
    self.images.each do |image|
      new_image = CosplayImage.create
      image.attributes.each do |k,v|
        next if k == 'id'
        if k == 'image_file_name'
          new_image[k] = v.sub(image.id.to_s, new_image.id.to_s)
        else
          new_image[k] = v
        end
      end
      new_image[:cosplay_gallery_id] = target.id
      FileUtils.cp(image.image.path, new_image.image.path)
      new_image.image.reprocess!
      new_image.save
    end
    self.update_attribute(:deleted, true)
  end

  # полное название галереи
  def title linked
    titles = title_components(linked).map {|c| c.map(&:name).join(' и ') }
    "Косплей #{titles.first} от #{titles.second}".html_safe
  end

  def title_components linked
    [characters.any? ? characters : [linked], cosplayers]
  end

  # подтверждена ли модератором галерея
  def confirmed?
    confirmed
  end

  # удалена ли модератором галерея
  def deleted?
    deleted
  end
end
