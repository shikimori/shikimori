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

  state_machine :state, initial: :pending do
    state :pending
    state :accepted do
      validates :approver, presence: true
    end
    state :rejected do
      validates :approver, presence: true
    end
    # отклонено автоматической post модераций
    state :post_rejected

    event(:accept) { transition %i[pending accepted] => :accepted }
    event(:accept_only) { transition pending: :accepted }
    event(:reject) { transition pending: :rejected }
    event(:post_reject) { transition %i[pending accepted] => :post_rejected }
    event(:cancel) do
      transition %i[accepted rejected post_rejected] => :pending
    end
  end
end
