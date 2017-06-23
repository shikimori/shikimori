class Contests::Progress
  method_object :contest

  def call
    started_matches = matches.select(&:can_start?).each(&:start!)
    finished_matches = matches.select(&:can_finish?).each(&:finish!)
    finished_round = current_round.finish! if current_round.can_finish?

    if started_matches.any? || finished_matches.any? || finished_round
      @contest.touch
    end
  end

private

  def matches
    @contest.current_round.matches
  end

  def current_round
    @contest.current_round
  end
end
