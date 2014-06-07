class GroupBan < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group, :user, presence: true

  after_create :leave_club

  def leave_club
    group.leave user
  end
end
