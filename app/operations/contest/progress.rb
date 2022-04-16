class Contest::Progress
  method_object :contest

  def call
    Rails.logger.info "Contest::Progress #{@contest.id}"

    matches_to_start = start_matches
    matches_to_finish = finish_matches

    Contest.transaction do
      if current_round.may_finish?
        round_to_finish = ContestRound::Finish.call current_round
      end

      if matches_to_start.any? || matches_to_finish.any? || round_to_finish
        @contest.touch
      end
    end
  end

private

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
