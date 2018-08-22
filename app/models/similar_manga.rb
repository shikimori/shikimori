class SimilarManga < ApplicationRecord
  belongs_to :src,
    class_name: Manga.name,
    foreign_key: :src_id,
    optional: true, # because it can imported from MAL for non existing manga
    touch: true
  belongs_to :dst,
    class_name: Manga.name,
    foreign_key: :dst_id,
    optional: true, # because it can imported from MAL for non existing manga
    touch: true
end
