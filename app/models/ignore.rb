# TODO: rename to UserIgnore
class Ignore < ApplicationRecord
  include AntispamConcern

  antispam(
    per_day: 300,
    user_id_key: :user_id
  )

  belongs_to :user
  belongs_to :target, class_name: 'User'

  validates :target_id, uniqueness: { scope: :user_id }
end
