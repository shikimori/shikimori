class AnimeVideoReport < ActiveRecord::Base
  extend Enumerize

  belongs_to :anime_video
  belongs_to :user
  belongs_to :approver, class_name: User.name, foreign_key: :approver_id

  enumerize :kind, in: [:uploaded, :broken, :wrong], predicates: true

  validates :user, presence: true
  validates :anime_video, presence: true
  validates :kind, presence: true

  scope :pending, -> { where state: 'pending' }
  scope :processed, -> { where(state: ['accepted', 'rejected']).order(updated_at: :desc) }

  state_machine :state, initial: :pending do
    state :pending
    state :accepted do
      validates :approver, presence: true
    end
    state :rejected do
      validates :approver, presence: true
    end

    event :accept do
      transition pending: :accepted
    end

    event :reject do
      transition pending: :rejected
    end

    event :cancel do
      transition [:accepted, :rejected] => :pending
    end

    before_transition pending: :accepted do |anime_video_report, transition|
      anime_video_report.approver = transition.args.first
      anime_video_report.anime_video.update_attribute :state, anime_video_report.kind
    end

    before_transition pending: :rejected do |anime_video_report, transition|
      anime_video_report.approver = transition.args.first
      if anime_video_report.kind.uploaded?
        anime_video_report.anime_video.reject!
      end
    end

    before_transition [:accepted, :rejected] => :pending do |anime_video_report, transition|
      anime_video_report.approver = transition.args.first
      anime_video_report.anime_video.update_attribute :state, 'working'
    end
  end
end
