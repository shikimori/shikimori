class Contest::Finish
  method_object :contest

  def call
    Rails.logger.info "Contest::Finish #{@contest.id}"

    Contest.transaction do
      @contest.finish!
      @contest.update!(
        finished_on: Time.zone.today,
        cached_uniq_voters_count: Contests::UniqVotersCount.call(@contest)
      )

      Contests::ObtainWinners.call @contest
      Contests::Votes.call(@contest).delete_all

      reset_user_vote_key
      Messages::CreateNotification.new(@contest).contest_finished
    end
  end

private

  def reset_user_vote_key
    User.update_all @contest.user_vote_key => false
  end
end
