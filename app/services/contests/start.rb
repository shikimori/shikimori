class Contests::Start
  method_object :contest

  def call
    @contest.update started_on: Time.zone.today if expired_started_on?
    Contests::GenerateRounds.call @contest if should_generate_rounds?
    @contest.rounds.first.start!
  end

private

  def expired_started_on?
    @contest.started_on < Time.zone.today
  end

  def should_generate_rounds?
    return true if @contest.rounds.none?

    @contest.rounds.any? do |round|
      round.matches.any? { |match| match.started_on < Time.zone.today }
    end
  end
end
