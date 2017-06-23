class Contest::Finish
  method_object :contest

  def call
    Contest.transaction { finish_contest }
  end

private

  def finish_contest
    @contest.finish!
    @contest.update! finished_on: Time.zone.today

    User.update_all @contest.user_vote_key => false
    Messages::CreateNotification.new(@contest).contest_finished
  end
end
