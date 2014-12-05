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

  after_create :auto_check

  def doubles state=nil
    reports = AnimeVideoReport
      .where(anime_video_id: anime_video_id)
      .where('id != ?', id)
    reports = reports.where(state: state) if state
    reports.count
  end

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
      anime_video_report.find_doubles.update_all(
        approver_id: transition.args.first.id,
        state: :accepted
      )
    end

    before_transition pending: :rejected do |anime_video_report, transition|
      anime_video_report.approver = transition.args.first
      if anime_video_report.kind.uploaded?
        anime_video_report.anime_video.reject!
      end
      anime_video_report.find_doubles.update_all(
        approver_id: transition.args.first.id,
        state: :rejected
      )
    end

    before_transition [:accepted, :rejected] => :pending do |anime_video_report, transition|
      anime_video_report.approver = transition.args.first
      prev_state = anime_video_report.uploaded? ? 'uploaded' : 'working'
      anime_video_report.anime_video.update_attribute :state, prev_state
      anime_video_report.find_doubles(transition.from).update_all(
        approver_id: transition.args.first.id,
        state: transition.to
      )
    end
  end

  def find_doubles state='pending'
    AnimeVideoReport.where(
      kind: kind,
      state: state,
      anime_video_id: anime_video_id
    )
  end

private
  def auto_check
    AnimeOnline::ReportWorker.delay_for(10.seconds).perform_async id
  end
end
