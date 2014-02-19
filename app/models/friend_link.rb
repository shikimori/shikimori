class FriendLink < ActiveRecord::Base
  belongs_to :src, class_name: User.name, foreign_key: :src_id, touch: true
  belongs_to :dst, class_name: User.name, foreign_key: :dst_id, touch: true
end
