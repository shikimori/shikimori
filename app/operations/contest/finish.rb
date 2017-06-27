class Contest::Finish
  method_object :contest

  def call
    Contest.transaction do
      @contest.finish!
      @contest.update! finished_on: Time.zone.today

      reset_user_vote_key
      Messages::CreateNotification.new(@contest).contest_finished
    end
  end

private

  def reset_user_vote_key
    User.update_all @contest.user_vote_key => false
  end
end
