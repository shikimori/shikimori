class ContestMatch::Start
  method_object :contest_match

  def call
    ContestMatch.transaction do
      @contest_match.start!
      reset_user_vote_key
      update_right
      update_left
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
      .where(@contest_match.round.contest.user_vote_key => false)
      .update_all(@contest_match.round.contest.user_vote_key => true)
  end
end
