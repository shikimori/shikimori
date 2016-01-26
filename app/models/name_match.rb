class NameMatch < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :anime,
    class_name: Anime.name,
    foreign_key: :target_id
  belongs_to :manga,
    class_name: Manga.name,
    foreign_key: :target_id

  validates :target_id, :target_type, :phrase, presence: true
  validates :group, :priority,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  GROUPS = [
    :predefined,
    :name,
    :alt, :alt2, :alt3,
    :russian, :russian_alt
  ]
end
