class UserToken < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true

  def unlink_forbidden?
    (user.encrypted_password.blank? || user.email =~ /^generated_/) && user.user_tokens.one?
  end
end
