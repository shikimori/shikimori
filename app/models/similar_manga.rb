class SimilarManga < ActiveRecord::Base
  belongs_to :src, :class_name => Manga.name, :foreign_key => :src_id
  belongs_to :dst, :class_name => Manga.name, :foreign_key => :dst_id
end
