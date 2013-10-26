class ContestUserVote < ActiveRecord::Base
  belongs_to :match, class_name: ContestMatch.name, foreign_key: :contest_match_id, touch: true
  belongs_to :user

  validates :user, :match, presence: true
end
