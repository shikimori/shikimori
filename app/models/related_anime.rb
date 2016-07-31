class RelatedAnime < ActiveRecord::Base
  belongs_to :source, class_name: Anime.name, touch: true
  belongs_to :anime, touch: true
  belongs_to :manga, touch: true
end
