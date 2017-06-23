class ContestRound::Start
  method_object :contest_round

  def call
    ContestRound.transaction { start_round }
  end

private

  def start_round
    @contest_round.start!
    @contest_round.matches
      .select { |match| match.started_on <= Time.zone.today }
      .each(&:start!)

    # must reset @strategy becase it is cached
    @contest_round.contest.instance_variable_set('@strategy', nil)
  end
end
