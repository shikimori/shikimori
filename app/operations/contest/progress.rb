class Contest::Progress
  method_object :contest

  def call
    Contest.transaction { progress_contest }
  end

private

  def progress_contest
    ap matches.select(&:can_start?)
    ap matches.select(&:can_finish?)

    matches.select(&:can_start?).each(&:start!)
    matches.select(&:can_finish?).each(&:finish!)
    current_round.finish! if current_round.can_finish?
  end

  def matches
    @contest.current_round.matches
  end

  def current_round
    @contest.current_round
  end
end
