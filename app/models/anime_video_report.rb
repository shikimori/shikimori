class AnimeVideoReport < ApplicationRecord
  belongs_to :anime_video
  belongs_to :user
  belongs_to :approver,
    class_name: User.name,
    foreign_key: :approver_id,
    optional: true

  enumerize :kind, in: %i[uploaded broken wrong other], predicates: true

  validates :user, presence: true
  validates :anime_video, presence: true
  validates :kind, presence: true
end
