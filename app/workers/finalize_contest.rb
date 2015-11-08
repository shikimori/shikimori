class FinalizeContest
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    retry: true,
    dead: false,
    queue: :high_priority
  )

  def perform contest_id
    contest = Contest.find contest_id

    contest.update finished_on: Time.zone.today
    User.update_all contest.user_vote_key => false
    NotificationsService.new(contest).contest_finished
  end
end
