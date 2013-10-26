class CosplayGalleryLink < ActiveRecord::Base
  belongs_to :linked, :polymorphic => true
  belongs_to :cosplay_gallery
  belongs_to :anime, :foreign_key => :linked_id
  belongs_to :character, :foreign_key => :linked_id
  belongs_to :cosplayer, :foreign_key => :linked_id
end
