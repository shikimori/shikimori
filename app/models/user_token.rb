class UserToken < ApplicationRecord
  belongs_to :user
  validates :user, presence: true

  def unlink_forbidden?
    (user.encrypted_password.blank? || user.generated_email?) && user.user_tokens.one?
  end
end
