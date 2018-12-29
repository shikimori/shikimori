class ContestMatch::Start
  method_object :contest_match

  def call
    Rails.logger.info "ContestMatch::Start #{@contest_match.id}"

    ContestMatch.transaction do
      @contest_match.start!
      reset_user_vote_key
      update_right
      update_left

      if first_match?
        Messages::CreateNotification.new(contest).contest_started
      end
    end
  end

private

  def update_right
    @contest_match.update! right: nil if @contest_match.right.nil?
  end

  def update_left
    if @contest_match.left.nil? && @contest_match.right.present?
      @contest_match.update!(
        left: @contest_match.right,
        right: nil
      )
    end
  end

  def reset_user_vote_key
    User
      .where(contest.user_vote_key => false)
      .update_all(contest.user_vote_key => true)
  end

  def first_match?
    contest_round.number == 1 && @contest_match == contest_round.matches.first
  end

  def contest_round
    @contest_match.round
  end

  def contest
    contest_round.contest
  end
end
