class SimilarAnime < ActiveRecord::Base
  belongs_to :src, class_name: Anime.name, foreign_key: :src_id
  belongs_to :dst, class_name: Anime.name, foreign_key: :dst_id
end
