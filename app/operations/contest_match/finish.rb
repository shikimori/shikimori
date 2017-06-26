class ContestMatch::Finish
  method_object :contest_match

  def call
    ContestRound.transaction do
      @contest_match.finish!
      @contest_match.update winner_id: winner_id
    end
  end

private

  # rubocop:disable MethodLength
  def winner_id
    if @contest_match.right_id.nil?
      @contest_match.left_id

    elsif left_votes?
      @contest_match.left_id

    elsif right_votes?
      @contest_match.right_id

    elsif scores?
      max_scored

    else
      @contest_match.left_id
    end
  end
  # rubocop:enable MethodLength

  def left_votes?
    @contest_match.left_votes > @contest_match.right_votes
  end

  def right_votes?
    @contest_match.right_votes > @contest_match.left_votes
  end

  def scores?
    @contest_match.left.respond_to?(:score) &&
      @contest_match.right.respond_to?(:score)
  end

  def max_scored
    if @contest_match.right.score > @contest_match.left.score
      @contest_match.right_id
    else
      @contest_match.left_id
    end
  end
end
