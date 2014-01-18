class CosplayGallery < ActiveRecord::Base
  include Commentable

  has_many :image,
    class_name: 'CosplayImage',
    limit: 1,
    conditions: {deleted: false}

  has_many :images,
    class_name: 'CosplayImage',
    conditions: {deleted: false},
    dependent: :destroy,
    order: :position

  has_many :deleted_images,
    class_name: 'CosplayImage',
    conditions: {deleted: true},
    order: :position

  has_many :links,
    class_name: 'CosplayGalleryLink',
    dependent: :destroy
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
  def full_title(anime)
    @full_title_ ||= ("Косплей %s от %s" % [
        self.characters.empty? ? anime.name : (
            self.characters.size == 1 ? self.characters.first.name : (
                self.characters.size == 2 ? self.characters.map {|v| v.name }.join(' и ') : anime.name
              )
          ),
        self.cosplayers.size == 1 ? self.cosplayers.first.name : self.cosplayers.map {|v| v.name }.join(' и ')
      ]).html_safe
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

class CosplayerProfile < CosplayGallery
end

class CosplayerEveryDay < CosplayGallery
end

class CosplayEvent < CosplayGallery
end

class CosplayOther < CosplayGallery
end
