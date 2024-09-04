class Contest::Progress
  method_object :contest

  def call
    matches_freezed = freeze_matches
    matches_started = start_matches
    matches_finished = finish_matches

    Contest.transaction do
      if current_round.may_finish?
        round_to_finish = ContestRound::Finish.call current_round
      end

      if matches_started.any? || matches_freezed.any? || matches_finished.any? ||
          round_to_finish
        @contest.touch
      end
    end
  end

private

  def freeze_matches
    matches
      .select(&:may_to_freezed?)
      .each(&:to_freezed!)
  end

  def start_matches
    matches
      .select(&:may_start?)
      .each { |match| ContestMatch::Start.call match }
  end

  def finish_matches
    matches
      .select(&:may_finish?)
      .each { |match| ContestMatch::Finish.call match }
  end

  def matches
    @contest.current_round.matches
  end

  def current_round
    @contest.current_round
  end
end
