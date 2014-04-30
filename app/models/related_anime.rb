class RelatedAnime < ActiveRecord::Base
  belongs_to :source, class_name: Anime.name
  belongs_to :anime
  belongs_to :manga
end
