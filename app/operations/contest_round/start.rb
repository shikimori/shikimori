class ContestRound::Start
  method_object :contest_round

  def call
    Rails.logger.info "ContestRound::Start #{@contest_round.id}"

    ContestRound.transaction do
      @contest_round.start!

      start_matches

      # must reset @strategy becase it is cached
      reset_strategy
    end
  end

private

  def start_matches
    @contest_round.matches
      .select { |match| match.started_on <= Time.zone.today }
      .each { |match| ContestMatch::Start.call match }
  end

  def reset_strategy
    @contest_round.contest.instance_variable_set('@strategy', nil)
  end
end
