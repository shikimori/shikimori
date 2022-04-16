class ClubRole < ApplicationRecord
  belongs_to :user
  belongs_to :club, counter_cache: true, touch: true

  after_create :accept_invites
  before_destroy :destroy_invites

  enumerize :role, in: %i[member admin], defualt: :member, predicates: true

  validates :role, presence: true

private

  def accept_invites
    club_invites.each(&:close!)
  end

  def destroy_invites
    club_invites.destroy_all
  end

  def club_invites
    ClubInvite.where(dst_id: user_id, club_id: club_id)
  end
end
