class GroupBan < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group, :user, presence: true

  after_create :leave_club
  after_create :delete_invites

private
  def leave_club
    group.leave user
  end

  def delete_invites
    group.invites
      .where(src: user)
      .delete_all

    group.invites
      .where(dst: user)
      .delete_all
  end
end
