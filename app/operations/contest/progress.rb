class Contest::Progress
  method_object :contest

  def call
    Contest.transaction { progress_contest }
  end

private

  def progress_contest
    matches_to_start = start_matches
    matches_to_finish = finish_matches

    if current_round.can_finish?
      round_to_finish = ContestRound::Finish.call current_round
    end

    if matches_to_start.any? || matches_to_finish.any? || round_to_finish
      @contest.touch
    end
  end

  def start_matches
    matches
      .select(&:can_start?)
      .each { |match| ContestMatch::Start.call match }
  end

  def finish_matches
    matches
      .select(&:can_finish?)
      .each { |match| ContestMatch::Finish.call match }
  end

  def matches
    @contest.current_round.matches
  end

  def current_round
    @contest.current_round
  end
end
