class CosplayGalleryLink < ApplicationRecord
  belongs_to :linked, polymorphic: true
  belongs_to :cosplay_gallery
  belongs_to :anime, foreign_key: :linked_id, optional: true
  belongs_to :character, foreign_key: :linked_id, optional: true
  belongs_to :cosplayer, foreign_key: :linked_id, optional: true
end
