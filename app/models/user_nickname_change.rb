class UserNicknameChange < ApplicationRecord
  belongs_to :user

  validates :user, :value, presence: true
  validates :value, uniqueness: { scope: [:user_id] }

  default_scope -> { where is_deleted: false }
end
