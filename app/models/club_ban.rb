class ClubBan < ApplicationRecord
  belongs_to :club
  belongs_to :user

  validates :club, :user, presence: true

  after_create :leave_club
  after_create :delete_invites

private

  def leave_club
    club.leave user
  end

  def delete_invites
    club.invites.where(src: user).delete_all
    club.invites.where(dst: user).delete_all
  end
end
