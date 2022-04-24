# TODO: rename to UserIgnore
class Ignore < ApplicationRecord
  belongs_to :user
  belongs_to :target, class_name: 'User'

  validates :target_id, uniqueness: { scope: :user_id }
end
