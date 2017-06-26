class Contest::Finish
  method_object :contest

  def call
    Contest.transaction do
      @contest.finish!
      @contest.update! finished_on: Time.zone.today

      User.update_all @contest.user_vote_key => false
      Messages::CreateNotification.new(@contest).contest_finished
    end
  end
end
