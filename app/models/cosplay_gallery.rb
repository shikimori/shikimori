# frozen_string_literal: true

class CosplayGallery < ApplicationRecord
  include Translation
  include TopicsConcern

  acts_as_votable

  belongs_to :user, optional: true

  has_many :image, -> { where(deleted: false).limit(1) },
    class_name: CosplayImage.name

  has_many :images, -> { where(deleted: false).order(:position) },
    class_name: CosplayImage.name,
    dependent: :destroy

  has_many :deleted_images, -> { where(deleted: true).order(:position) },
    class_name: CosplayImage.name

  has_many :links, class_name: CosplayGalleryLink.name, dependent: :destroy
  has_many :cosplayers,
    through: :links,
    source: :linked,
    source_type: Cosplayer.name

  has_many :animes,
    through: :links,
    source: :linked,
    source_type: Anime.name

  has_many :mangas,
    through: :links,
    source: :linked,
    source_type: Manga.name

  has_many :characters,
    through: :links,
    source: :linked,
    source_type: Character.name

  validates :description, :description_cos_rain, length: { maximum: 16_384 }

  scope :visible, -> { where confirmed: true, deleted: false }

  accepts_nested_attributes_for :images, :deleted_images

  def to_param
    format(
      '%<id>d-%<target>s',
      id: id,
      target: target.gsub(/&#\d{4};/, '-').gsub(/[^A-z0-9]+/, '-').gsub(/^-|-$/, '')
    )
  end

  # копирует все картинки в target, а текущую галерею помечает удалённой
  def move_to target
    images.each do |image|
      new_image = CosplayImage.create
      image.attributes.each do |k, v|
        next if k == 'id'

        new_image[k] = if k == 'image_file_name'
                         v.sub(image.id.to_s, new_image.id.to_s)
                       else
                         v
                       end
      end
      new_image[:cosplay_gallery_id] = target.id
      FileUtils.cp(image.image.path, new_image.image.path)
      new_image.image.reprocess!
      new_image.save
    end
    update_attribute(:deleted, true)
  end

  # полное название галереи
  def name linked = send(:any_linked)
    titles = title_components(linked).map { |c| c.map(&:name).to_sentence }

    i18n_t('title', cosplay: titles.first, cosplayer: titles.second).html_safe
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

  def self.without_topics
    visible
      .includes(:animes, :mangas, :characters, :topic)
      .reject { |v| v.topics.present? }
      .select { |v| v.animes.any? || v.mangas.any? || v.characters.any? }
  end

  def topic_user
    User.find User::MESSANGER_ID
  end

private

  def any_linked
    animes.first || mangas.first || characters.first
  end
end
