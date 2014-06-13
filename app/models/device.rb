class Device < ActiveRecord::Base
  belongs_to :user

  enum platform: { android: 0, ios: 1 }

  validates :user, :platform, :token, presence: true
  validates :token, uniqueness: { scope: :user }
end
