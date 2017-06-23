class Contest::Progress
  method_object :contest

  def call
    Contest.transaction { progress_contest }
  end

private

  def progress_contest
    matches_to_start = matches.select(&:can_start?).each(&:start!)
    matches_to_finish = matches.select(&:can_finish?).each(&:finish!)

    if current_round.can_finish?
      round_to_finish = ContestRound::Finish.call current_round
    end

    if matches_to_start.any? || matches_to_finish.any? || round_to_finish
      @contest.touch
    end
  end

  def matches
    @contest.current_round.matches
  end

  def current_round
    @contest.current_round
  end
end
