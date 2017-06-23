class Contests::Finalize
  method_object :contest

  def call
    @contest.update! finished_on: Time.zone.today
    User.update_all @contest.user_vote_key => false
    Messages::CreateNotification.new(@contest).contest_finished
  end
end
