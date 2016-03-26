class AnimeVideoReport < ActiveRecord::Base
  extend Enumerize

  belongs_to :anime_video
  belongs_to :user
  belongs_to :approver, class_name: User.name, foreign_key: :approver_id

  enumerize :kind, in: [:uploaded, :broken, :wrong], predicates: true

  validates :user, presence: true
  validates :anime_video, presence: true
  validates :kind, presence: true

  scope :pending, -> { where(state: 'pending').order(created_at: :asc) }
  scope :processed, -> { where(state: ['accepted', 'rejected']).order(updated_at: :desc) }

  after_create :auto_check
  after_create :auto_accept

  def doubles state=nil
    reports = AnimeVideoReport
      .where(anime_video_id: anime_video_id)
      .where.not(id: id)

    if state
      reports.where! 'state = :state and user_id != :guest_id',
        state: state, guest_id: User::GUEST_ID
    end

    reports.size
  end

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

    event :accept do
      transition [:pending, :accepted] => :accepted
    end

    event :accept_only do
      transition pending: :accepted
    end

    event :reject do
      transition pending: :rejected
    end

    event :post_reject do
      transition [:pending, :accepted] => :post_rejected
    end

    event :cancel do
      transition [:accepted, :rejected] => :pending
    end

    before_transition pending: :accepted do |report, transition|
      report.approver = transition.args.first

      report.process_doubles(:accepted)
      report.process_conflict(:uploaded, :rejected)

      report.anime_video.send "#{report.kind}!" unless transition.event == :accept_only
    end

    before_transition pending: :rejected do |report, transition|
      report.approver = transition.args.first
      report.process_doubles(:rejected)
      report.anime_video.reject! if report.uploaded?
    end

    before_transition [:accepted, :rejected] => :pending do |report, transition|
      report.approver = transition.args.first
      prev_state = report.uploaded? ? 'uploaded' : 'working'
      report.anime_video.update_attribute :state, prev_state
    end
  end

  def process_doubles to_state
    AnimeVideoReport
      .where(
        kind: kind,
        state: 'pending',
        anime_video_id: anime_video_id
      )
      .update_all(
        approver_id: approver.id,
        state: to_state
      )
  end

  def process_conflict conflict_kind, to_state
    AnimeVideoReport
      .where(
        kind: conflict_kind,
        state: 'pending',
        anime_video_id: anime_video_id
      )
      .update_all(
        approver_id: approver.id,
        state: to_state
      )
  end

private

  def auto_check
    AnimeOnline::ReportWorker.perform_in 10.seconds, id
  end

  def auto_accept
    accept! user if user.video_moderator?
  end
end
