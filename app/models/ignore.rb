# TODO: rename to UserIgnore
class Ignore < ApplicationRecord
  belongs_to :user
  belongs_to :target, class_name: User.name, foreign_key: 'target_id'

  validates :user, :target, presence: true
  validates :target_id, uniqueness: { scope: :user_id }
end
