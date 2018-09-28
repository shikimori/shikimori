class UserRatesLog < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true, optional: true
  belongs_to :oauth_application, optional: true

  belongs_to :anime, foreign_key: :target_id, optional: true
  belongs_to :manga, foreign_key: :target_id, optional: true

  validates :ip, :user_agent, presence: true
end
