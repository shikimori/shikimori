class AnimeVideoReport < ApplicationRecord
  belongs_to :anime_video
  belongs_to :user
  belongs_to :approver,
    class_name: 'User',
    optional: true

  enumerize :kind, in: %i[uploaded broken wrong other], predicates: true

  validates :kind, presence: true
end
