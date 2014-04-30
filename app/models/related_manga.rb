class RelatedManga < ActiveRecord::Base
  belongs_to :source, class_name: Manga.name
  belongs_to :anime
  belongs_to :manga
end
