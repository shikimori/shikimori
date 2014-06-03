class GroupBan < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group, :user, presence: true
end
