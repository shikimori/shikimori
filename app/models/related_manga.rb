class RelatedManga < ApplicationRecord
  belongs_to :source, class_name: Manga.name
  belongs_to :anime, touch: true, optional: true
  belongs_to :manga, touch: true, optional: true
end
