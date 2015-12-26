# TODO: переименовать в ClubRole
# TODO: заменить status на state_machine
class ClubRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :club, counter_cache: true, touch: true

  after_create :accept_invites
  before_destroy :destroy_invites

  enumerize :role, in: [:member, :admin], defualt: :member, predicates: true

  validates :user, :club, :role, presence: true

private

  def accept_invites
    ClubInvite.where(dst_id: user_id, club_id: club_id).each do |v|
      v.update_columns status: ClubInviteStatus::Accepted
      v.message.update! read: true if v.message
    end
  end

  def destroy_invites
    ClubInvite.where(dst_id: user_id, club_id: club_id).destroy_all
  end
end
