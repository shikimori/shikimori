class FriendLink < ApplicationRecord
  include AntispamConcern

  belongs_to :src, class_name: 'User', touch: true
  belongs_to :dst, class_name: 'User', touch: true

  antispam(
    per_day: 300,
    user_id_key: :src_id
  )
end
