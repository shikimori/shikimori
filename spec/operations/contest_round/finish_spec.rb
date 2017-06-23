describe ContestRound::Finish do
  include_context :timecop

  let(:operation) { ContestRound::Finish.new round }

  let(:contest) { create :contest, :with_5_members, state: 'started' }
  let(:round) { create :contest_round, contest: contest }
  let(:next_round) { nil }

  # context 'before finished' do
  before do
    contest.strategy.fill_round_with_matches round
    ContestRound::Start.call round
    round.matches.each { |v| v.finished_on = Time.zone.yesterday }
  end

  before do
    allow(round).to receive(:next_round).and_return next_round

    allow(Messages::CreateNotification)
      .to receive(:new)
      .with(round)
      .and_return(notification_service)
    allow(ContestRound::Start).to receive :call
    allow(round.strategy).to receive :advance_members

    allow(Contest::Finish).to receive :call
  end
  let(:notification_service) { double round_finished: nil }

  subject! { operation.call }

  it do
    round.matches.each do |match|
      expect(match).to be_finished
    end

    expect(round).to be_finished
  end

  context 'last round' do
    let(:next_round) { nil }
    it do
      expect(notification_service).to_not have_received :round_finished
      expect(ContestRound::Start).to_not have_received :call
      expect(round.strategy).to_not have_received :advance_members

      expect(Contest::Finish).to have_received(:call).with contest
    end
  end

  context 'not last round' do
    let(:next_round) { create :contest_round, contest: contest }

    it do
      expect(notification_service).to have_received :round_finished
      expect(ContestRound::Start).to have_received(:call).with(next_round)
      expect(round.strategy)
        .to have_received(:advance_members)
        .with(next_round, round)


      expect(Contest::Finish).to_not have_received :call
    end
  end
  # context 'after finished' do
    # before do
      # allow(Messages::CreateNotification)
        # .to receive(:new)
        # .and_return notification_service
    # end

    # let(:next_round) { create :round }
    # let(:notification_service) do
      # double round_finished: true, contest_finished: true
    # end

    # before do
      # contest.strategy.fill_round_with_matches round
      # ContestRound::Start.call round
      # round.matches.each { |v| v.finished_on = Time.zone.yesterday }
    # end

    # it 'starts&fills next round' do
      # allow(round).to receive(:next_round).and_return next_round

      # expect(next_round).to receive :start!
      # expect(round.strategy).to receive(:advance_members).with next_round, round
      # expect(notification_service).to receive :round_finished
      # # expect(notification_service).to_not receive :contest_finished

      # round.finish!
    # end

    # it 'finishes contest' do
      # round.finish!
      # expect(round.contest).to be_finished
      # expect(notification_service).to_not receive :round_finished
      # # expect(notification_service).to receive :contest_finished
    # end
  # end
end
