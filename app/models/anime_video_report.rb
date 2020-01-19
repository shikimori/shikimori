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

  scope :pending, -> { where(state: :pending).order(created_at: :asc) }
  scope :processed,
    -> { where(state: %i[accepted rejected]).order(updated_at: :desc) }

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

    before_transition pending: :accepted do |report, transition|
      report.approver = transition.args.first

      report.process_doubles(:accepted)
      report.process_conflict(:uploaded, :rejected)

      unless transition.event == :accept_only || report.other?
        report.anime_video.send "#{report.kind}!"
      end
    end

    before_transition pending: :rejected do |report, transition|
      report.approver = transition.args.first
      report.process_doubles(:rejected)
      report.anime_video.reject! if report.uploaded?
    end

    before_transition %i[accepted rejected] => :pending do |report, transition|
      report.approver = transition.args.first
      prev_state = report.uploaded? ? 'uploaded' : 'working'
      report.anime_video.update_attribute :state, prev_state
    end
  end

  def doubles state = nil
    reports = AnimeVideoReport
      .where(anime_video_id: anime_video_id)
      .where.not(id: id)

    if state
      reports.where! 'state = :state and user_id != :guest_id',
        state: state, guest_id: User::GUEST_ID
    end

    reports.size
  end

  def process_doubles to_state
    pending_reports(kind).update_all(
      approver_id: approver.id,
      state: to_state,
      updated_at: Time.zone.now
    )
  end

  def process_conflict conflict_kind, to_state
    pending_reports(conflict_kind).update_all(
      approver_id: approver.id,
      state: to_state,
      updated_at: Time.zone.now
    )
  end

private

  def pending_reports kind
    AnimeVideoReport.where(
      kind: kind,
      state: 'pending',
      anime_video_id: anime_video_id
    )
  end
end
